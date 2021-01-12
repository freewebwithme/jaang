defmodule Jaang.Checkout.LineItem do
  use Ecto.Schema
  alias Jaang.Checkout.LineItem
  alias Jaang.ProductManager
  alias Jaang.Product
  alias Jaang.Repo

  import Ecto.Changeset
  import Ecto.Query

  @derive Jason.Encoder
  embedded_schema do
    field :product_id, :integer
    field :store_id, :integer
    field :image_url, :string
    field :product_name, :string
    field :category_name, :string
    field :sub_category_name, :string
    field :unit_name, :string
    field :on_sale, :boolean
    field :original_price, Money.Ecto.Amount.Type
    field :original_total, Money.Ecto.Amount.Type
    field :discount_percentage, :string
    field :quantity, :integer
    field :price, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type

    timestamps(type: :utc_datetime)
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
      :on_sale,
      :original_price,
      :original_total,
      :discount_percentage,
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

        # get available product price
        # check if current product is on sale
        [product_price] = product.product_prices

        # Set price depends on on_sale value
        current_price =
          if(product_price.on_sale) do
            product_price.sale_price
          else
            product_price.original_price
          end

        changeset
        |> put_change(:image_url, product_image.image_url)
        |> put_change(:product_name, product.name)
        |> put_change(:price, current_price)
        |> put_change(:unit_name, product.unit_name)
        |> put_change(:store_id, product.store_id)
        |> put_change(:category_name, product.category_name)
        |> put_change(:sub_category_name, product.sub_category_name)
        |> put_change(:on_sale, product_price.on_sale)
        # In case product is on sale, I will display original price in the client.
        # that is why I keep original_price
        |> put_change(:original_price, product_price.original_price)
        |> put_change(:discount_percentage, product_price.discount_percentage)
    end
  end

  def set_total(changeset) do
    quantity = get_field(changeset, :quantity)
    price = get_field(changeset, :price)
    total = Money.multiply(price, quantity)

    original_price = get_field(changeset, :original_price)
    original_total = Money.multiply(original_price, quantity)

    changeset
    |> put_change(:total, total)
    |> put_change(:original_total, original_total)
  end
end
