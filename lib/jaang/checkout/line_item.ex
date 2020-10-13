defmodule Jaang.Checkout.LineItem do
  use Ecto.Schema

  embedded_schema do
    field :product_id, :integer
    field :product_name, :string
    field :unit_name, :string
    field :quantity, :integer
    field :price, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type
  end
end
