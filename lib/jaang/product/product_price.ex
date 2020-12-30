defmodule Jaang.Product.ProductPrice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Product.ProductPrice
  alias Jaang.Repo
  import Ecto.Query

  schema "product_prices" do
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    field :discount_percentage, :string
    field :on_sale, :boolean
    field :original_price, Money.Ecto.Amount.Type
    field :sale_price, Money.Ecto.Amount.Type

    belongs_to :product, Jaang.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%ProductPrice{} = product_price, attrs) do
    product_price
    |> cast(attrs, [
      :start_date,
      :end_date,
      :discount_percentage,
      :on_sale,
      :original_price,
      :sale_price,
      :product_id
    ])
    |> calculate_discount_percentage()
  end

  defp calculate_discount_percentage(changeset) do
    on_sale = get_change(changeset, :on_sale)

    if(on_sale) do
      original_price = get_change(changeset, :original_price)
      sale_price = get_change(changeset, :sale_price)

      # Calculate rate of discount
      discount = Money.subtract(original_price, sale_price)

      [rate_of_discount] =
        (discount.amount / original_price.amount * 100)
        |> Float.round()
        |> Float.to_string()
        |> String.split(".")
        |> Enum.take(1)

      changeset = put_change(changeset, :discount_percentage, "#{rate_of_discount}%")
      changeset
    else
      changeset
    end
  end

  def create_product_price(product, attrs) do
    %ProductPrice{}
    |> changeset(attrs)
    |> put_change(:product_id, product.id)
    |> Repo.insert()
  end

  def update_product_price(%ProductPrice{} = product_price, attrs) do
    product_price
    |> changeset(attrs)
    |> Repo.update!()
  end

  def delete_product_price(%ProductPrice{} = product_price) do
    product_price |> Repo.delete()
  end

  def list_product_price(product_id) do
    Repo.all(from pp in ProductPrice, where: pp.product_id == ^product_id)
  end

  def price_valid?(start_date, end_date) do
    interval = Timex.Interval.new(from: start_date, until: end_date)
    Timex.now() in interval
  end
end
