defmodule Jaang.Checkout.LineItem do
  use Ecto.Schema
  alias Jaang.Checkout.LineItem
  alias Jaang.ProductManager

  import Ecto.Changeset

  embedded_schema do
    field :product_id, :integer
    field :product_name, :string
    field :unit_name, :string
    field :quantity, :integer
    field :price, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type
  end

  @doc false
  def changeset(%LineItem{} = line_item, attrs) do
    line_item
    |> cast(attrs, [:product_id, :product_name, :unit_name, :quantity, :price, :total])
    |> set_product_details()
    |> set_total()
    |> validate_required([:product_id, :product_name, :unit_name, :quantity, :price])
  end

  def set_product_details(changeset) do
    case get_change(changeset, :product_id) do
      nil ->
        changeset

      product_id ->
        product = ProductManager.get_product(product_id)

        changeset
        |> put_change(:product_name, product.name)
        |> put_change(:price, product.regular_price)
        |> put_change(:unit_name, product.unit_name)
    end
  end

  def set_total(changeset) do
    quantity = get_field(changeset, :quantity)
    price = get_field(changeset, :price)
    total = Money.multiply(price, quantity)

    changeset
    |> put_change(:total, total)
  end
end
