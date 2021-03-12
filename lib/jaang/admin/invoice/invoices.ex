defmodule Jaang.Admin.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query
  alias Jaang.Invoice.Invoices
  alias Jaang.Notification.OneSignal
  alias Jaang.Admin.EmployeeAccountManager

  # 1 Get all invoices whose status is submitted, packed, on_the_way, delivered
  # set up per page option
  # set up pagination
  @doc """
  Get all invoices whose status is submitted, packed, on_the_way, delivered.
  Returns invoice list groupbed by status
  There will be only one order because I filters with store_id
  """
  def get_unfulfilled_invoices(store_id) do
    today = Timex.today()

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
    Repo.one(query) |> Repo.preload([:orders, [user: :profile], :employees])
  end

  @doc """
  Assigns employees to invoice with invoice status.
  Update order's status too.
  employees could be a single shopper and a single driver.
  It will be used when a shopper starts shopping(:shopping) and
  a driver picked up the order(:on_the_way)
  """
  def assign_employee_to_invoice(invoice_id, employee_id, status) do
    employee = EmployeeAccountManager.get_employee(employee_id)
    invoice = get_invoice(invoice_id)
    # get order from invoice to update order's status
    # There will always be only 1 order in invoice at this moment
    [order] = Enum.take(invoice.orders, 1)
    # TODO: assign same employee to order
    {:ok, invoice} =
      invoice
      |> Ecto.Changeset.change(%{status: status, orders: [%{status: status, id: order.id}]})
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
        # Broadcast to store employee
        Invoices.broadcast_to_employee(invoice, "invoice_updated")
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

  # This function is for Admin Dashboard
  defp update_and_broadcast_invoice(invoice, status) do
    invoice
    |> Invoice.changeset(%{status: status})
    |> Repo.update()
    |> Invoices.broadcast(:invoice_updated)
  end
end
