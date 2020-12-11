defmodule Jaang.Invoice.Invoices do
  alias Jaang.{Invoice, Repo}

  @doc """
  Create empty invoice
  """
  def create_invoice(user) do
    attrs = %{
      delivery_fee: "0",
      driver_tip: "0",
      sales_tax: "0",
      service_fee: "0",
      subtotal: "0",
      total: "0",
      status: :cart,
      user_id: user.id
    }

    Invoice.changeset(%Invoice{}, attrs)
    |> Repo.insert!()
  end
end
