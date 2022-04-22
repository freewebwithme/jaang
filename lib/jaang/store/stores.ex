defmodule Jaang.Store.Stores do
  @moduledoc """
  Function module for Store
  """
  alias Jaang.{Repo, Store, Product, Category}
  alias Jaang.Product.ProductPrice

  def create_store(attrs) do
    %Store{}
    |> Store.changeset(attrs)
    |> Repo.insert()
  end

  def change_store(%Store{} = store, attrs) do
    store
    |> Store.changeset(attrs)
  end

  def get_store(id) do
    Repo.get(Store, id)
  end

  def get_all_stores() do
    Repo.all(Store)
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
