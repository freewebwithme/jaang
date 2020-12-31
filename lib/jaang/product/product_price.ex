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

  def create_product_price(product_id, attrs) do
    %ProductPrice{}
    |> changeset(attrs)
    |> put_change(:product_id, product_id)
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

  @doc """
  Return not on sale, regular price
  """
  def get_product_price(product_id) do
    now = Timex.now()
    Repo.one(from pp in ProductPrice, where: pp.product_id == ^product_id and ^now < pp.end_date)
  end

  # @timezone "America/Los_Angeles"

  @doc """
  Creating sale price for product needs 3 steps
  1. Get original price from current price and Update current product price's end date to sales
     start date before 1 seccond so as soon as current end date expired, start sales.
  2. Create new ProductPrice with start and end date with sales price
  3. Create new ProductPrice for after sales event expired.

  params:
  product_id
  sale_price = %Money{}
  start_date and end_date = Timex.to_datetime({{2020, 12, 30}, {8, 30, 00}}, "America/Los_Angeles")
  """
  def create_on_sale_price(product_id, sale_price, start_date, end_date) do
    # get product price to obtain regular price and update end_date to sale's start date
    old_pp = get_product_price(product_id)
    IO.inspect(old_pp)
    original_price = old_pp.original_price
    # Update old product price end_date
    update_attrs = %{
      end_date: Timex.subtract(start_date, Timex.Duration.from_seconds(1))
    }

    update_product_price(old_pp, update_attrs)

    # create new on sale price
    sales_attrs = %{
      # Timex.to_datetime({{2020, 12, 30}, {8, 30, 00}}, @timezone),
      start_date: start_date,
      # Timex.to_datetime({{2020, 12, 30}, {8, 32, 00}}, @timezone),
      end_date: end_date,
      on_sale: true,
      original_price: original_price,
      sale_price: sale_price
    }

    create_product_price(product_id, sales_attrs)

    # create regular price. This will be used after sales expired.
    attrs = %{
      start_date: Timex.add(end_date, Timex.Duration.from_seconds(1)),
      end_date: Timex.add(end_date, Timex.Duration.from_days(7300)),
      on_sale: false,
      sale_price: Money.new(0),
      original_price: original_price
    }

    create_product_price(product_id, attrs)
  end
end
