defmodule Jaang.Product.MarketPrice do
  @moduledoc """
  In store market price
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Product.{MarketPrice, ProductPrice}
  alias Jaang.Repo
  import Ecto.Query

  schema "market_prices" do
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
  def changeset(%MarketPrice{} = market_price, attrs) do
    market_price
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

  @timezone "America/Los_Angeles"

  def create_market_price(product_id, attrs) do
    # When creating product, create also product_price with end date 20 years after.
    mp_attrs = %{
      start_date: Timex.now(@timezone),
      end_date: Timex.add(Timex.now(@timezone), Timex.Duration.from_days(7300)),
      on_sale: false,
      sale_price: Money.new(0)
    }

    merged_attrs = Map.merge(mp_attrs, attrs)

    %MarketPrice{}
    |> changeset(merged_attrs)
    |> put_change(:product_id, product_id)
    |> Repo.insert()
  end

  @doc """
  Create market price and product price with same data but
  different on prices

  Before add new market price, get recent market price and
  change end_date to new market price's start_date - 1 second.
  `attrs` should contain `original_price`

  This function is called in `products` module
  """
  def create_market_price_with_product_price(product_id, attrs) do
    # Get recent market price
    case get_market_price(product_id) do
      # There is no available market price so just create new one
      nil ->
        {:ok, market_price} = create_market_price(product_id, attrs)
        calculated_price = calculate_price(market_price.original_price)
        calculated_sale_price = calculate_price(market_price.sale_price)

        ProductPrice.create_product_price(product_id, %{
          start_date: market_price.start_date,
          end_date: market_price.end_date,
          discount_percentage: market_price.discount_percentage,
          on_sale: market_price.on_sale,
          original_price: calculated_price,
          sale_price: calculated_sale_price
        })

      old_market_price ->
        # Found recent(last) market price, so changed its end_date to new one's start_date - 1 second
        {:ok, market_price} = create_market_price(product_id, attrs)
        calculated_price = calculate_price(market_price.original_price)
        calculated_sale_price = calculate_price(market_price.sale_price)

        # Change end_date for market price
        update_market_price(old_market_price, %{
          end_date: Timex.subtract(market_price.start_date, Timex.Duration.from_seconds(1))
        })

        # Change end_date for Product price(customer price)

        case ProductPrice.get_product_price(product_id) do
          nil ->
            {:ok, _product_price} =
              ProductPrice.create_product_price(product_id, %{
                start_date: market_price.start_date,
                end_date: market_price.end_date,
                discount_percentage: market_price.discount_percentage,
                on_sale: market_price.on_sale,
                original_price: calculated_price,
                sale_price: calculated_sale_price
              })

          old_product_price ->
            {:ok, product_price} =
              ProductPrice.create_product_price(product_id, %{
                start_date: market_price.start_date,
                end_date: market_price.end_date,
                discount_percentage: market_price.discount_percentage,
                on_sale: market_price.on_sale,
                original_price: calculated_price,
                sale_price: calculated_sale_price
              })

            ProductPrice.update_product_price(old_product_price, %{
              end_date: Timex.subtract(product_price.start_date, Timex.Duration.from_seconds(1))
            })
        end
    end
  end

  # Calculate price from market price(In-store price) to Product price(customer price)
  # Add 20% margin
  # Formula
  # Price = Unit Cost/(1 – Gross Margin Percentage) = $100/(1 – .25) = $133.33
  def calculate_price(%Money{} = price) do
    # divide price by 8 and take first one
    [divided_price] = Money.divide(price, 8) |> Enum.take(1)

    margined_price = Money.multiply(divided_price, 10)
    margined_price
  end

  def update_market_price(%MarketPrice{} = market_price, attrs) do
    market_price
    |> changeset(attrs)
    |> Repo.update!()
  end

  def delete_market_price(%MarketPrice{} = market_price) do
    market_price |> Repo.delete()
  end

  def list_market_price(product_id) do
    Repo.all(from mp in MarketPrice, where: mp.product_id == ^product_id)
  end

  def price_valid?(start_date, end_date) do
    interval = Timex.Interval.new(from: start_date, until: end_date)
    Timex.now() in interval
  end

  @doc """
  Return not on sale, regular price
  """
  def get_market_price(product_id) do
    query =
      from mp in MarketPrice,
        where:
          mp.product_id == ^product_id and
            fragment("now() between ? and ?", mp.start_date, mp.end_date)

    Repo.one(query)
  end

  # @timezone "America/Los_Angeles"

  @doc """
  Creating sale price for product needs 3 steps
  1. Get original price from current price and Update current product price's end date to sales
     start date before 1 seccond so as soon as current end date expired, Sale starts.
  2. Create new MarketPrice with start and end date with sales price
  3. Create new MarketPrice for after sales event expired.

  Need these steps for both MarketPrice and ProductPrice

  params:
  product_id
  sale_price = %Money{}
  start_date and end_date = Timex.to_datetime({{2020, 12, 30}, {8, 30, 00}}, "America/Los_Angeles")
  """
  def create_on_sale_price(product_id, sale_price, start_date, end_date) do
    # get product price to obtain regular price and update end_date to sale's start date
    # For Market Price
    old_mp = get_market_price(product_id)
    IO.inspect(old_mp)
    original_price = old_mp.original_price

    # Update old product price's end_date
    update_attrs = %{
      end_date: Timex.subtract(start_date, Timex.Duration.from_seconds(1))
    }

    update_market_price(old_mp, update_attrs)

    # For ProductPrice
    old_pp = ProductPrice.get_product_price(product_id)

    ProductPrice.update_product_price(old_pp, update_attrs)

    # For Market Price
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

    create_market_price(product_id, sales_attrs)

    # For Product Price
    # create new on sale Price
    ProductPrice.create_product_price(product_id, sales_attrs)

    # For Market Price
    # create regular price. This will be used after sales expired.
    attrs = %{
      start_date: Timex.add(end_date, Timex.Duration.from_seconds(1)),
      # Add 20 years
      end_date: Timex.add(end_date, Timex.Duration.from_days(7300)),
      on_sale: false,
      sale_price: Money.new(0),
      original_price: original_price
    }

    create_market_price(product_id, attrs)

    # For Product Price
    ProductPrice.create_product_price(product_id, attrs)
  end
end
