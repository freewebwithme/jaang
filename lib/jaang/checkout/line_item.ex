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
    field :on_sale, :boolean
    field :market_price, Money.Ecto.Amount.Type
    field :original_price, Money.Ecto.Amount.Type
    field :original_total, Money.Ecto.Amount.Type
    field :discount_percentage, :string
    field :quantity, :integer
    field :final_quantity, :integer
    field :weight, :float
    field :weight_based, :boolean
    field :price, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type
    field :barcode, :string
    field :status, Ecto.Enum, values: [:ready, :not_ready, :sold_out], default: :not_ready
    field :replacement_id, :integer
    field :has_replacement, :boolean
    field :refund_reason, :string

    # embeds_many :replacements, LineItem, on_replace: :delete

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
      :final_quantity,
      :weight,
      :category_name,
      :sub_category_name,
      :price,
      :total,
      :inserted_at,
      :updated_at,
      :barcode,
      :status,
      :market_price,
      :weight_based,
      :replacement_id,
      :has_replacement,
      :refund_reason
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
      :price,
      :weight_based
    ])
  end

  @doc """
  Update status, quantity(could be 1 if unit is pack, or could be float(1.5) if unit is lb or oz)
  and total.
  Include :price, :original_price field to set_total()
  """
  def changeset_for_employee_task(%LineItem{} = line_item, attrs) do
    line_item
    |> cast(attrs, [
      :quantity,
      :total,
      :status,
      :price,
      :original_price,
      :weight,
      :final_quantity,
      :refund_reason,
      :replacement_id,
      :has_replacement
    ])
    |> set_total()
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

        # Get market price to display it in employee app
        [market_price] = product.market_prices

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
        # put market price for employee app
        |> put_change(:market_price, market_price.original_price)
        |> put_change(:discount_percentage, product_price.discount_percentage)
        |> put_change(:barcode, product.barcode)
        |> put_change(:weight_based, product.weight_based)
    end
  end

  # def set_total(changeset) do
  #  quantity = get_field(changeset, :quantity)
  #  price = get_field(changeset, :price)
  #  total = Money.multiply(price, quantity)

  #  original_price = get_field(changeset, :original_price)
  #  original_total = Money.multiply(original_price, quantity)

  #  changeset
  #  |> put_change(:total, total)
  #  |> put_change(:original_total, original_total)
  # end

  def set_total(changeset) do
    case get_change(changeset, :weight) do
      nil ->
        # Check if final_quantity value is available
        # and if available using it to calculate the total
        quantity =
          case get_field(changeset, :final_quantity) do
            nil ->
              # no final_quantity return :quantity
              get_field(changeset, :quantity)

            0 ->
              # no final_quantity return :quantity
              get_field(changeset, :quantity)

            final_quantity when is_integer(final_quantity) ->
              final_quantity
          end

        price = get_field(changeset, :price)
        total = Money.multiply(price, quantity)

        original_price = get_field(changeset, :original_price)
        original_total = Money.multiply(original_price, quantity)

        changeset
        |> put_change(:total, total)
        |> put_change(:original_total, original_total)

      weight ->
        price = get_field(changeset, :price)
        total = Money.multiply(price, weight)

        original_price = get_field(changeset, :original_price)
        original_total = Money.multiply(original_price, weight)

        changeset
        |> put_change(:total, total)
        |> put_change(:original_total, original_total)
    end
  end
end
