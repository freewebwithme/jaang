defmodule Jaang.Store.Stores do
  @moduledoc """
  Function module for Store
  """
  alias Jaang.{Repo, Store, Product, Category}

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

  # * Create function that returns
  # * first 10 items from each category for front page
  def get_products_for_homescreen(limit, store_id) do
    raw_query =
      "SELECT * FROM categories c LEFT JOIN LATERAL (SELECT p.* FROM products p WHERE c.id = p.category_id AND p.store_id = #{
        store_id
      } LIMIT #{limit}) p ON 1=1"

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
    product_cols = Enum.slice(query_result.columns, 3, 21)
    product_rows = Enum.map(query_result.rows, &Enum.slice(&1, 3, 21))
    products = Enum.map(product_rows, &Repo.load(Product, {product_cols, &1}))

    grouped_products = Enum.group_by(products, & &1.category_id)

    categories_ready =
      categories
      |> Enum.map(&%{&1 | products: Map.get(grouped_products, &1.id)})
      |> Enum.sort_by(& &1.name)

    categories_ready
  end
end
