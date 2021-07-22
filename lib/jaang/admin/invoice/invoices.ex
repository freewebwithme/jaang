defmodule Jaang.Admin.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query
  alias Jaang.Invoice.Invoices
  alias Jaang.Checkout.{Order, Calculate, Carts}
  alias Jaang.{OrderManager, StripeManager}
  alias Jaang.Notification.OneSignal
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Admin.EmployeeTask.EmployeeTasks

  # 1 Get all invoices whose status is submitted, packed, on_the_way, delivered
  # set up per page option
  # set up pagination
  @doc """
  Get all invoices whose status is submitted, packed, on_the_way, delivered.
  Returns invoice list groupbed by status
  There will be only one order because I filters with store_id
  """
  def get_unfulfilled_invoices(store_id) do
    today = Timex.to_date(Timex.now("America/Los_Angeles"))

    query =
      from i in Invoice,
        where:
          i.status not in [:cart, :refunded, :delivered] and
            i.delivery_date == ^today,
        order_by: i.delivery_order,
        join: o in assoc(i, :orders),
        where: o.store_id == ^store_id,
        preload: [orders: o]

    Repo.all(query)
    |> Repo.preload(:employees)
    |> Repo.preload(user: :profile)
    |> Enum.group_by(fn invoice -> invoice.status end)
  end

  @doc """
  Returns a list of invoice matching the given `criteria`

  Example Criteria:

  [
   paginate: %{page: 2, per_page: 5},
   sort: %{sort_by: :delivery_time, sort_order: :asc}
   filter_by: %{by_state: :submitted}
  ]
  """
  def get_invoices(criteria) when is_list(criteria) do
    query = from i in Invoice, order_by: [desc: i.inserted_at]

    Enum.reduce(criteria, query, fn
      {:user_by, %{user_id: user_id}}, query ->
        from q in query, where: q.user_id == ^user_id

      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query,
          offset: ^((page - 1) * per_page),
          limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query, order_by: [{^sort_order, ^sort_by}]

      {:filter_by, %{by_state: state}}, query ->
        case state == :all do
          true ->
            from(q in query)

          _ ->
            from q in query, where: q.status == ^state
        end

      {:search_by, %{search_by: search_by, search_term: term}}, query ->
        search_pattern = "%#{term}%"

        case search_by do
          "Invoice number" ->
            from q in query, where: ilike(q.invoice_number, ^search_pattern)

          _ ->
            query
        end
    end)
    |> Repo.all()
    |> Repo.preload(user: :profile)
  end

  def get_invoices() do
    Repo.all(Invoice)
  end

  @doc """
  Get invoice by id and preload orders and user information
  """

  def get_invoice(invoice_id) do
    query = from i in Invoice, where: i.id == ^invoice_id
    Repo.one(query) |> Repo.preload([[orders: :employees], [user: :profile], :employees])
  end

  def get_assigned_invoices(employee_id, limit) do
    query =
      from i in Invoice,
        join: e in assoc(i, :employees),
        where: e.id == ^employee_id,
        limit: ^limit,
        order_by: [desc: i.inserted_at],
        preload: [employees: e]

    Repo.all(query)
  end

  @doc """
  Assigns employees to invoice with invoice status.
  Update order's status too.
  employees could be a single shopper and a single driver.
  It will be used when a shopper starts shopping(:shopping) and
  a driver picked up the order(:on_the_way)
  """
  def assign_employee_to_invoice(invoice_id, employee_id, status, store_id) do
    employee = EmployeeAccountManager.get_employee(employee_id)
    invoice = get_invoice(invoice_id)
    # get order from invoice to update order's status
    IO.puts("Printing store id: #{store_id}")
    [order] = Enum.filter(invoice.orders, fn order -> order.store_id == store_id end)
    not_updated_order = Enum.filter(invoice.orders, fn order -> order.store_id != store_id end)

    {:ok, updated_order} =
      Order.assign_employee_changeset(order, employee, status) |> Repo.update()

    {:ok, invoice} =
      invoice
      |> Ecto.Changeset.change(%{status: status, orders: [updated_order | not_updated_order]})
      |> Ecto.Changeset.put_assoc(:employees, [employee | invoice.employees])
      |> Repo.update()

    Invoices.broadcast_to_employee(invoice, "invoice_updated")
    {:ok, invoice}
  end

  def update_invoice(invoice_id, attrs) do
    invoice = get_invoice(invoice_id)

    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Finalize invoice.
  copy final line_items from employee_task to same order
  1. update order
  2. update invoice(sales_tax, item_adjustment(0), total, total_items, number_of_bags)
  3. Invoice's status updated when all orders(from different store) are packed.  then
     updated invoice's status to packed.  If every orders not ready, keep it :shopping status
  """
  # TODO: Adjust this function
  def finalize_invoice(invoice_id, employee_task_id, number_of_bags) do
    invoice = get_invoice(invoice_id)
    employee_task = EmployeeTasks.get_employee_task_by_id(employee_task_id)

    # Copy employee_task.line_items to order.line_items
    # ! Get correct order from invoice
    [order] = Enum.filter(invoice.orders, &(&1.id == employee_task.order_id))

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
    {:ok, _updated_order} =
      OrderManager.update_cart(order, %{line_items: line_item_maps, status: :packed})

    # Get updated invoice
    updated_invoice = get_invoice(invoice_id)

    sales_tax = Calculate.calculate_sales_tax(updated_invoice.orders, :ready)
    subtotal = Calculate.calculate_subtotals(updated_invoice.orders)
    # set to 0
    item_adjustment = Money.new(0)
    # Count only ready items(not sold out items)
    total_items = Carts.count_total_item(updated_invoice.orders, :ready)
    status = check_all_orders_status(updated_invoice)

    total =
      Calculate.calculate_final_total(
        updated_invoice.driver_tip,
        subtotal,
        updated_invoice.delivery_fee,
        sales_tax,
        item_adjustment
      )

    # Now update invoice
    attrs = %{
      subtotal: subtotal,
      sales_tax: sales_tax,
      item_adjustment: item_adjustment,
      total: total,
      total_items: total_items,
      status: status,
      number_of_bags: number_of_bags
    }

    with {:ok, invoice} <- Jaang.Invoice.Invoices.update_invoice(updated_invoice, attrs),
         {:ok, _} <-
           StripeManager.capture_payment_intent(updated_invoice.pm_intent_id, total.amount) do
      Invoices.broadcast_to_employee(invoice, "invoice_updated")
      {:ok, invoice}
    else
      {:error, _error} ->
        {:error, "Can't finalize invoice"}
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
  Update invoice with photo urls
  Convert list of string photo_urls to
  photo_urls = [%{photo_url: ""}]
  """
  def update_invoice_with_receipt_photos(invoice_id, photo_urls) do
    converted_photo_urls =
      Enum.map(photo_urls, fn photo_url ->
        %{photo_url: photo_url}
      end)

    attrs = %{receipt_photos: converted_photo_urls}

    invoice = get_invoice(invoice_id)

    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  def update_invoice_status(invoice_id, :shopping = status) do
    invoice = get_invoice(invoice_id)
    IO.puts("Status is changed Shopping")

    case update_and_broadcast_invoice(invoice, status) do
      {:ok, invoice} ->
        # Broadcast to store employee
        IO.puts("invoice status changed, notifying employee...")
        Invoices.broadcast_to_employee(invoice, "invoice_updated")
        # Send push notification to flutter client
        OneSignal.create_notification(
          "JaangCart",
          "Our shopper just starts shopping!",
          invoice.user_id
        )

        {:ok, invoice}

      {:error, _reason} ->
        :error
    end
  end

  def update_invoice_status(invoice_id, :packed = status) do
    invoice = get_invoice(invoice_id)
    IO.puts("Status is changed to on the way")

    case update_and_broadcast_invoice(invoice, status) do
      {:ok, invoice} ->
        # Send push notification to driver
        # OneSignal.create_notification(
        #  "JaangCart",
        #  "Our shopper just starts shopping!",
        #  invoice.user_id
        # )
        # Broadcast to store employee
        Invoices.broadcast_to_employee(invoice, "invoice_updated")

        {:ok, invoice}

      {:error, _reason} ->
        :error
    end
  end

  def update_invoice_status(invoice_id, :on_the_way = status) do
    invoice = get_invoice(invoice_id)
    IO.puts("Status is changed to on the way")

    case update_and_broadcast_invoice(invoice, status) do
      {:ok, invoice} ->
        # Broadcast to store employee
        Invoices.broadcast_to_employee(invoice, "invoice_updated")

        # Send push notification to flutter client
        OneSignal.create_notification("JaangCart", "Your order is on the way!", invoice.user_id)
        {:ok, invoice}

      {:error, _reason} ->
        :error
    end
  end

  def update_invoice_status(invoice_id, :delivered = status) do
    IO.puts("Status is changed to delivered")
    invoice = get_invoice(invoice_id)

    case update_and_broadcast_invoice(invoice, status) do
      {:ok, invoice} ->
        # !TODO: update invoice.orders status also
        # Broadcast to store employee
        Invoices.broadcast_to_employee(invoice, "invoice_updated")

        # Send push notification to flutter client
        OneSignal.create_notification("JaangCart", "Your order is delivered!", invoice.user_id)

        {:ok, invoice}

      {:error, _reason} ->
        :error
    end
  end

  def update_invoice_status(invoice_id, status) do
    invoice = get_invoice(invoice_id)
    update_and_broadcast_invoice(invoice, status)
  end

  @doc """
  This function is used jaangcart_worker app
  Update invoice status and also order(cart) status together
  """

  def update_invoice_status(invoice_id, :on_the_way = status, store_id) do
    IO.puts("Status is changing to on the way")
    invoice = get_invoice(invoice_id)
    # filter order by store_id
    order =
      Enum.find(invoice.orders, nil, fn order ->
        order.store_id == store_id
      end)

    with {:ok, _order} <- Carts.update_cart(order, %{status: status}),
         {:ok, invoice} <- update_and_broadcast_invoice(invoice, status) do
      # Broadcast to store employee
      Invoices.broadcast_to_employee(invoice, "invoice_updated")

      # Send push notification to flutter client
      OneSignal.create_notification("JaangCart", "Your order is on the way!", invoice.user_id)
      {:ok, invoice}
    else
      {:error, _changeset} -> :error
    end
  end

  # This function is for Admin Dashboard
  defp update_and_broadcast_invoice(invoice, status) do
    invoice
    |> Invoice.changeset(%{status: status})
    |> Repo.update()
    |> Invoices.broadcast(:invoice_updated)
  end
end
