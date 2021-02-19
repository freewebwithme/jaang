defmodule Jaang.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query

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
    Repo.get_by(Invoice, id: invoice_id)
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

  @topic inspect(__MODULE__)

  def subscribe do
    IO.puts("Subscribe to #{@topic}")
    Phoenix.PubSub.subscribe(Jaang.PubSub, @topic)
  end

  def broadcast({:ok, invoice}, event) do
    Phoenix.PubSub.broadcast(
      Jaang.PubSub,
      @topic,
      {event, invoice}
    )

    {:ok, invoice}
  end

  def broadcast({:error, _reason} = error, _event), do: error
end
