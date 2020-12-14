defmodule Jaang.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}
  import Ecto.Query

  @doc """
  Create empty invoice
  """
  def create_invoice(user_id) do
    attrs = %{
      delivery_fee: Money.new(0),
      driver_tip: Money.new(0),
      sales_tax: Money.new(0),
      service_fee: Money.new(0),
      subtotal: Money.new(0),
      total: Money.new(0),
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
    |> Repo.update!()
  end
end
