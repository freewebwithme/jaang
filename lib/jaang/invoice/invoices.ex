defmodule Jaang.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query
  alias Jaang.Admin.Account.Employee.Employee

  @doc """
  Create empty invoice
  """
  def create_invoice(user_id) do
    attrs = %{
      invoice_number: UUID.uuid1(),
      delivery_fee: Money.new(0),
      driver_tip: Money.new(0),
      sales_tax: Money.new(0),
      service_fee: Money.new(0),
      subtotal: Money.new(0),
      total: Money.new(0),
      total_items: 0,
      status: :cart,
      user_id: user_id
    }

    Invoice.changeset(%Invoice{}, attrs)
    |> Repo.insert!()
  end

  def get_invoice_in_cart(user_id) do
    query = from i in Invoice, where: i.user_id == ^user_id and i.status == :cart
    Repo.one(query) |> Repo.preload(:orders)
  end

  def get_invoice_by_id(invoice_id) do
    Repo.get_by(Invoice, id: invoice_id) |> Repo.preload(employees: :employee_profile)
  end

  def get_or_create_invoice(user_id) do
    case get_invoice_in_cart(user_id) do
      nil ->
        # There is no invoice. Create one
        create_invoice(user_id)

      invoice ->
        invoice
    end
  end

  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
    |> broadcast(:invoice_updated)
  end

  @doc """
  Get all invoices excluding :cart status
  """
  def get_invoices(user_id, limit, offset) do
    query =
      from i in Invoice,
        where: i.user_id == ^user_id and i.status != :cart,
        order_by: [desc: i.inserted_at],
        limit: ^limit,
        offset: ^offset

    Repo.all(query)
  end

  @doc """
  Get packed invoice count for employee
  """
  def count_packed_invoice_for_employee(employee_id) do
    employee = Repo.get_by(Employee, id: employee_id) |> Repo.preload(:invoices)

    invoices =
      Enum.reduce(employee.invoices, [], fn invoice, acc ->
        if(invoice.status == :packed) do
          [invoice | acc]
        else
          acc
        end
      end)

    Enum.count(invoices)
  end

  @topic inspect(__MODULE__)

  def subscribe() do
    IO.puts("Subscribe to #{@topic}")
    Phoenix.PubSub.subscribe(Jaang.PubSub, @topic)
  end

  def subscribe(_), do: :error

  def broadcast({:ok, invoice}, event) do
    Phoenix.PubSub.broadcast(
      Jaang.PubSub,
      @topic,
      {event, invoice}
    )

    {:ok, invoice}
  end

  def broadcast({:error, _reason} = error, _event), do: error

  @doc """
  Broadcast to store employees for new order or updated order status
  """

  def broadcast_to_employee(invoice, event) do
    IO.puts("Broadcasting to employee(event name) : #{event}")
    store_ids = Enum.map(invoice.orders, & &1.store_id)

    IO.puts("Store id counts: #{Enum.count(store_ids)}")

    Enum.map(store_ids, fn store_id ->
      # conver it string
      store_id = Integer.to_string(store_id)

      JaangWeb.Endpoint.broadcast(
        "store:" <> store_id,
        event,
        %{}
      )
    end)
  end
end
