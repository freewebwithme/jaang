defmodule Jaang.Admin.Order.Orders do
  import Ecto.Query
  alias Jaang.Repo

  alias Jaang.Admin.EmployeeTask.EmployeeTasks
  alias Jaang.Checkout.Order
  alias Jaang.Checkout.Carts
  alias Jaang.OrderManager
  alias Jaang.Checkout.Calculate
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Notification.OneSignal

  @doc """
  Returns a list of order matching the given `criteria`

  Example Criteria:

  [
   paginate: %{page: 2, per_page: 5},
   sort: %{sort_by: :delivery_time, sort_order: :asc}
   filter_by: %{by_state: :submitted}
  ]
  """
  def get_orders(store_id \\ nil, criteria) when is_list(criteria) do
    query =
      if is_nil(store_id) do
        from o in Order, order_by: [desc: o.inserted_at], preload: [user: :profile]
      else
        from o in Order, where: o.store_id == ^store_id, order_by: [desc: o.inserted_at], preload: [user: :profile]
      end

    Enum.reduce(criteria, query, fn
      {:user_by, %{user_id: user_id}}, query ->
        from q in query, where: q.user_id == ^user_id

      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query,
          order_by: [{^sort_order, ^sort_by}]

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        IO.puts("Inspecting search term")
        IO.inspect(search_by)
        search_pattern = "%#{term}"
        search_by = String.to_atom(search_by)

        case search_by do
          :"Order id" ->
            IO.puts("search by order id")
            {order_id, _rest} = Integer.parse(term)
            from q in query, where: q.id == ^order_id

          _ ->
            query
        end

      {:filter_by, %{by_state: state}}, query ->
        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end
    end)
    |> Repo.all()
    |> Repo.preload([employees: :employee_profile], user: :profile)
  end

  def get_order(store_id, order_id) do
    query =
      from o in Order,
        where: o.store_id == ^store_id and o.id == ^order_id

    Repo.one(query)
  end

  def get_order(order_id) do
    query =
      from o in Order,
        where: o.id == ^order_id

    Repo.one(query)
    |> Repo.preload([:refund_request, [employees: :employee_profile], [user: :profile]])
  end

  def get_assigned_orders(employee_id, limit) do
    query =
      from o in Order,
        join: e in assoc(o, :employees),
        where: e.id == ^employee_id,
        limit: ^limit,
        order_by: [desc: o.inserted_at],
        preload: [employees: e]

    Repo.all(query)
  end

  def get_unfulfilled_orders(store_id) do
    today = Timex.to_date(Timex.now("America/Los_Angeles"))

    query =
      from o in Order,
        where:
          o.status not in [:cart, :refunded, :delivered] and
            o.delivery_date == ^today and
            o.store_id == ^store_id,
        order_by: o.delivery_order

    Repo.all(query)
    |> Repo.preload(:employees)
    |> Repo.preload(user: :profile)
    |> Enum.group_by(fn invoice -> invoice.status end)
  end

  @doc """
  Get packed order count for employee
  """
  def count_packed_order_for_employee(employee_id) do
    employee = EmployeeAccountManager.get_employee(employee_id)

    orders =
      Enum.reduce(employee.orders, [], fn order, acc ->
        if(order.status == :packed) do
          [order | acc]
        else
          acc
        end
      end)

    Enum.count(orders)
  end

  @doc """
  Update order with photo urls
  Convert list of string photo_urls to
  photo_urls = [%{photo_url: ""}]
  """
  def update_order_with_receipt_photos(order_id, photo_urls) do
    converted_photo_urls =
      Enum.map(photo_urls, fn photo_url ->
        %{photo_url: photo_url}
      end)

    attrs = %{receipt_photos: converted_photo_urls}

    get_order(order_id)
    |> Carts.update_cart(attrs)
  end

  @doc """
  Assigns employees to order with order status.
  Update invoice's status too.
  It will be used when a shopper starts shopping(:shopping) and
  when a shopper start to deliver the order(:on_the_way)
  """
  def assign_employee_to_order(order_id, employee_id, status, store_id) do
    employee = EmployeeAccountManager.get_employee(employee_id)
    order = get_order(order_id)
    # get order from invoice to update order's status
    IO.puts("Printing store id: #{store_id}")

    {:ok, updated_order} =
      Order.assign_employee_changeset(order, employee, status) |> Repo.update()

    Carts.broadcast_to_employee({:ok, updated_order}, "order_updated")
  end

  @doc """
  Finalize order.
  copy final line_items from employee_task to same order
  1. update order
  2. update order(sales_tax, item_adjustment(0), total, total_items, number_of_bags)
  3. Invoice's status updated when all orders(from different store) are packed.  then
     updated invoice's status to packed.  If every orders not ready, keep it :shopping status
  """
  def finalize_order(order_id, employee_task_id, number_of_bags) do
    order = get_order(order_id)
    employee_task = EmployeeTasks.get_employee_task_by_id(employee_task_id)

    # Copy employee_task.line_items to order.line_items

    # Convert line_items to map
    line_item_maps =
      Enum.map(employee_task.line_items, fn line_item ->
        if(line_item.has_replacement) do
          Map.update!(line_item, :replacement_item, fn value ->
            Map.from_struct(value)
          end)
          |> Map.from_struct()
        else
          Map.from_struct(line_item)
        end
      end)

    # Copy(updated) line items
    {:ok, updated_order} =
      OrderManager.update_cart(order, %{line_items: line_item_maps, status: :packed})

    sales_tax = Calculate.calculate_sales_tax_for_store(updated_order, :ready)
    total = Calculate.calculate_total(updated_order, :ready)
    # set to 0
    item_adjustment = Money.new(0)
    # Count only ready items(not sold out items)
    total_items = Calculate.count_total_item(updated_order, :ready)

    new_grand_total =
      Calculate.calculate_final_total(
        updated_order.delivery_tip,
        total,
        updated_order.delivery_fee,
        sales_tax,
        item_adjustment
      )

    # TODO: Check if updated grand_total is greater than captured amount.
    # Compoare grand totals
    # 0 => same
    # 1 => old grand total is greater, go on capture and update order
    # -1 => new grand total is greater, can't capture new grand total, use old value
    compare_result = Money.compare(updated_order.grand_total, new_grand_total)

    attrs =
      if(compare_result < 0) do
        %{
          total_items: total_items,
          status: :packed,
          number_of_bags: number_of_bags,
          item_adjustment: item_adjustment,
          finalized: true
        }
      else
        %{
          sales_tax: sales_tax,
          item_adjustment: item_adjustment,
          total: total,
          grand_total: new_grand_total,
          total_items: total_items,
          status: :packed,
          number_of_bags: number_of_bags,
          finalized: true
        }
      end

    # then use capted amount
    with {:ok, order} <- Carts.update_cart(updated_order, attrs) do
      {:ok, order}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def check_all_orders_status(invoice) do
    if(Enum.count(invoice.orders) <= 1) do
      [status] = Enum.map(invoice.orders, & &1.status)
      status
    else
      statuses =
        Enum.reduce(invoice.orders, [], fn order, acc ->
          [order.status | acc]
        end)
        |> Enum.uniq()

      if(Enum.any?(statuses, &(&1 == :refunded || &1 == :submitted || &1 == :shopping))) do
        # this invoice is not ready just return current invoice's status
        invoice.status
      else
        :packed
      end
    end
  end

  @doc """
  Update order and notify to admin and employee app
  and send notification to client
  attrs = %{}
  """
  def update_order_and_notify(order_id, attrs, status) do
    order = get_order(order_id)

    order
    |> update_and_broadcast_order(attrs)
    |> send_notification(status)
  end

  defp update_and_broadcast_order(order, attrs) do
    order
    |> Carts.update_cart(attrs)
    |> Carts.broadcast("order_updated")
    |> Carts.broadcast_to_employee("order_updated")
  end

  defp send_notification({:ok, order}, status) do
    case status do
      :shopping ->
        OneSignal.create_notification(
          "JaangCart",
          "Our shopper just starts shopping!",
          order.user_id
        )

      # in packed status, do not send notification to client
      :packed ->
        nil

      :on_the_way ->
        OneSignal.create_notification("JaangCart", "Your order is on the way!", order.user_id)

      :delivered ->
        OneSignal.create_notification("JaangCart", "Your order is delivered!", order.user_id)

      :refunded ->
        OneSignal.create_notification(
          "JaangCart",
          "Your refund is processing and it will take few business day.",
          order.user_id
        )

      :partially_refunded ->
        OneSignal.create_notification(
          "JaangCart",
          "Your refund is processing and it will take few business day.",
          order.user_id
        )
    end

    {:ok, order}
  end
end
