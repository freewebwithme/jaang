defmodule Jaang.Checkout.LineItem do
  use Ecto.Schema
  alias Jaang.Checkout.LineItem
  alias Jaang.ProductManager

  import Ecto.Changeset

  @derive Jason.Encoder
  embedded_schema do
    field :product_id, :integer
    field :store_id, :integer
    field :image_url, :string
    field :product_name, :string
    field :category_name, :string
    field :sub_category_name, :string
    field :unit_name, :string
    field :quantity, :integer
    field :price, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type

    timestamps()
  end

  @doc false
  def changeset(%LineItem{} = line_item, attrs) do
    line_item
    |> cast(attrs, [
      :product_id,
      :store_id,
      :product_name,
      :image_url,
      :unit_name,
      :quantity,
      :category_name,
      :sub_category_name,
      :price,
      :total,
      :inserted_at,
      :updated_at
    ])
    |> set_product_details()
    |> set_total()
    |> validate_required([
      :product_id,
      :store_id,
      :product_name,
      :category_name,
      :sub_category_name,
      :image_url,
      :unit_name,
      :quantity,
      :price
    ])
  end

  def set_product_details(changeset) do
    case get_change(changeset, :product_id) do
      nil ->
        changeset

      product_id ->
        product = ProductManager.get_product(product_id)
        # get first product images
        [product_image] = Enum.filter(product.product_images, fn pi -> pi.order == 1 end)

        changeset
        |> put_change(:image_url, product_image.image_url)
        |> put_change(:product_name, product.name)
        |> put_change(:price, product.regular_price)
        |> put_change(:unit_name, product.unit_name)
        |> put_change(:store_id, product.store_id)
        |> put_change(:category_name, product.category_name)
        |> put_change(:sub_category_name, product.sub_category_name)
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
