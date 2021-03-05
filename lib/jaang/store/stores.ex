defmodule Jaang.Store.Stores do
  @moduledoc """
  Function module for Store
  """
  alias Jaang.{Repo, Store, Product, Category}
  alias Jaang.Product.ProductPrice
  alias Jaang.Store.DeliveryDateTime

  def create_store(attrs) do
    %Store{}
    |> Store.changeset(attrs)
    |> Repo.insert()
  end

  def get_store(id) do
    Repo.get(Store, id)
  end

  def get_all_stores() do
    Repo.all(Store)
  end

  @available_hours [
    "9 am to 11 am",
    "11 am to 1 pm",
    "1 pm to 3 pm",
    "3 pm to 5 pm",
    "5 pm to 7 pm",
    "7 pm to 9 pm"
  ]

  @doc """
  Return available delivery datetime
  """
  def get_available_delivery_datetime() do
    # Get current local date time
    now = Timex.now("America/Los_Angeles")
    # Check if today is available to delivery.
    # 9 am to 7 pm to take an order
    start_hour =
      Timex.to_datetime(
        {{now.year, now.month, now.day}, {9, 00, 00}},
        "America/Los_Angeles"
      )

    close_hour =
      Timex.to_datetime(
        {{now.year, now.month, now.day}, {19, 00, 00}},
        "America/Los_Angeles"
      )

    case Timex.between?(now, start_hour, close_hour) do
      true ->
        # Delivery available now, filter delivery hours
        IO.puts("Delivery today is available")
        return_available_delivery_datetime(now)

      false ->
        if(Timex.before?(now, start_hour)) do
          # Delivery available now, filter delivery hours
          IO.puts("Delivery today is not available")
          return_available_delivery_datetime(now)
        else
          return_future_delivery_datetime(now)
        end
    end
  end

  ### Return available Delivery DateTime
  ### params: now = Timex.local()

  defp return_available_delivery_datetime(now) do
    delivery_datetimes = return_future_delivery_datetime(now)

    # Filter delivery hours for today.
    # Exclude current time + 2 hours
    if(now.minute > 0) do
      # Add 3 hours
      available_start_hour = Timex.add(now, Timex.Duration.from_hours(3))

      today_delivery_date_time = return_today_delivery_datetime(available_start_hour, now)
      [today_delivery_date_time | delivery_datetimes]
    else
      available_start_hour = Timex.add(now, Timex.Duration.from_hours(2))

      today_delivery_date_time = return_today_delivery_datetime(available_start_hour, now)
      [today_delivery_date_time | delivery_datetimes]
    end
  end

  ### return delivery datetime for today
  ### Filter out delivery time
  ### params: available_start_hour = DateTime
  ### now = Timex.local()

  def return_today_delivery_datetime(available_start_hour, now) do
    # If available_start_hour is even(2, 4, 6, 8, 10 am or pm)
    # make it odd hour(3, 5, 7, 9, 11)
    # Because available hours timelines have odd number hour

    {:ok, available_start_hour} =
      if(rem(available_start_hour.hour, 2) == 0) do
        IO.puts("even number")
        IO.inspect(available_start_hour)

        Timex.add(available_start_hour, Timex.Duration.from_hours(1))
        |> Timex.format("{h12} {am}")
      else
        IO.puts("odd number")
        IO.inspect(available_start_hour)
        available_start_hour |> Timex.format("{h12} {am}")
      end

    IO.puts("Printing available_start_hour")
    IO.inspect(available_start_hour)
    # Get index
    index =
      if(available_start_hour == "9 pm") do
        Enum.find_index(@available_hours, fn hour ->
          String.ends_with?(hour, available_start_hour)
        end)
      else
        Enum.find_index(@available_hours, fn hour ->
          String.starts_with?(hour, available_start_hour)
        end)
      end

    available_hours = Enum.slice(@available_hours, index, Enum.count(@available_hours))
    {:ok, month} = now |> Timex.format("{Mshort}")

    %DeliveryDateTime{
      delivery_day: "Today",
      delivery_date: now.day,
      delivery_month: month,
      available_hours: available_hours
    }
  end

  ### return delivery datetime including 3 days after

  defp return_future_delivery_datetime(now) do
    for x <- 1..3 do
      next_day = Timex.add(now, Timex.Duration.from_days(x))
      {:ok, month} = next_day |> Timex.format("{Mshort}")
      {:ok, name_of_day} = next_day |> Timex.format("%a", :strftime)

      %Jaang.Store.DeliveryDateTime{
        # 요일
        delivery_day: name_of_day,
        delivery_date: next_day.day,
        delivery_month: month,
        available_hours: @available_hours
      }
    end
  end

  # * Create function that returns
  # * first 10 items from each category for front page
  def get_products_for_homescreen(limit, store_id) do
    raw_query =
      "SELECT * FROM categories c LEFT JOIN LATERAL (SELECT p.* FROM products p WHERE c.id = p.category_id AND p.store_id = #{
        store_id
      } LIMIT #{limit}) p ON 1=1
      INNER JOIN product_prices
      ON p.id = product_prices.product_id
      WHERE NOW() BETWEEN product_prices.start_date AND product_prices.end_date
      "

    {:ok, result} = Repo.query(raw_query)

    result
    |> load_categories_for_homescreen()
  end

  def load_categories_for_homescreen(query_result) do
    # Build categories
    category_cols = Enum.slice(query_result.columns, 0, 3)
    category_rows = Enum.map(query_result.rows, &Enum.slice(&1, 0, 3))
    categories = Enum.map(category_rows, &Repo.load(Category, {category_cols, &1})) |> Enum.uniq()

    # TODO: If category or product schema changes, correct this slice number
    # Build products
    product_cols = Enum.slice(query_result.columns, 3, 19)
    product_rows = Enum.map(query_result.rows, &Enum.slice(&1, 3, 19))
    products = Enum.map(product_rows, &Repo.load(Product, {product_cols, &1}))

    # Build ProductPrice
    pp_cols = Enum.slice(query_result.columns, 23, 10)
    pp_rows = Enum.map(query_result.rows, &Enum.slice(&1, 23, 10))
    product_prices = Enum.map(pp_rows, &Repo.load(ProductPrice, {pp_cols, &1}))

    grouped_pp = Enum.group_by(product_prices, & &1.product_id)

    grouped_products =
      products
      |> Enum.map(&%{&1 | product_prices: Map.get(grouped_pp, &1.id)})
      |> Enum.group_by(& &1.category_id)

    # grouped_products = Enum.group_by(products, & &1.category_id)

    categories_ready =
      categories
      |> Enum.map(&%{&1 | products: Map.get(grouped_products, &1.id)})
      |> Enum.sort_by(& &1.name)

    categories_ready
  end

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
