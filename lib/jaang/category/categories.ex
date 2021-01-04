defmodule Jaang.Category.Categories do
  @moduledoc """
  Function module related to Category Schema
  """
  alias Jaang.Product
  alias Jaang.Product.ProductPrice
  alias Jaang.Category
  alias Jaang.Category.SubCategory
  alias Jaang.Repo
  import Ecto.Query

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def create_subcategory(category, attrs) do
    attrs = Map.put(attrs, :category_id, category.id)

    %SubCategory{}
    |> SubCategory.changeset(attrs)
    |> Repo.insert()
  end

  def get_category(id) do
    Repo.get(Category, id)
  end

  def list_categories() do
    Repo.all(Category)
  end

  # TODO: Add limit to products(Pagination)
  def get_products_by_category(category_id, store_id, limit) do
    query =
      from p in Product,
        where: p.category_id == ^category_id and p.store_id == ^store_id,
        join: pp in assoc(p, :product_prices),
        on: p.id == pp.product_id,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        preload: [product_prices: pp],
        limit: ^limit

    Repo.all(query)
  end

  def get_all_categories() do
    Repo.all(Category)
  end

  @doc """
  This function is used in category screen to
  display products by each sub category.
  It transform data to :sub_category_product in schema.ex
  """
  def get_products_by_sub_category(category_id, store_id, limit) do
    ##  "SELECT * FROM sub_categories sc LEFT JOIN LATERAL (SELECT p.* FROM products p WHERE p.sub_category_id = sc.id
    ##   AND p.store_id = #{store_id} LIMIT #{limit}) p
    ##  ON 1=1 WHERE sc.category_id = #{category_id}"
    raw_query = "SELECT * FROM sub_categories AS sc
	    LEFT JOIN LATERAL (SELECT p.* FROM products AS p
				WHERE p.sub_category_id = sc.id
       	AND p.store_id = #{store_id} LIMIT #{limit}) AS p
        ON 1=1

	    INNER JOIN product_prices AS pp
	    ON p.id = pp.product_id
	    WHERE NOW() BETWEEN pp.start_date AND pp.end_date

      AND sc.category_id = #{category_id}"

    {:ok, result} = Repo.query(raw_query)
    result |> load_category_items()
  end

  def load_category_items(query_result) do
    # Build sub categories
    subcategory_cols = Enum.slice(query_result.columns, 0, 3)
    subcategory_rows = Enum.map(query_result.rows, &Enum.slice(&1, 0, 3))

    sub_categories =
      Enum.map(subcategory_rows, &Repo.load(SubCategory, {subcategory_cols, &1})) |> Enum.uniq()

    # TODO: If subcategory or product schema changes, correct this slice number
    # Build products
    product_cols = Enum.slice(query_result.columns, 3, 19)
    product_rows = Enum.map(query_result.rows, &Enum.slice(&1, 3, 19))
    products = Enum.map(product_rows, &Repo.load(Product, {product_cols, &1}))

    # Build ProductPrices
    pp_cols = Enum.slice(query_result.columns, 22, 10)
    pp_rows = Enum.map(query_result.rows, &Enum.slice(&1, 22, 10))
    product_prices = Enum.map(pp_rows, &Repo.load(ProductPrice, {pp_cols, &1}))

    grouped_pp = Enum.group_by(product_prices, & &1.product_id)

    grouped_products =
      products
      |> Enum.map(&%{&1 | product_prices: Map.get(grouped_pp, &1.id)})
      |> Enum.group_by(& &1.sub_category_name)

    # {sub_categories, grouped_products}

    subcategories_ready =
      sub_categories
      |> Enum.map(&%{&1 | products: Map.get(grouped_products, &1.name)})
      |> Enum.sort_by(& &1.name)

    subcategories_ready
  end

  @doc """
  This function is used for sub category screen
  returns list of product
  """
  def get_products_by_sub_category_name(sub_category_name, store_id, limit, offset) do
    query =
      from p in Product,
        where: p.sub_category_name == ^sub_category_name and p.store_id == ^store_id,
        join: pp in assoc(p, :product_prices),
        on: p.id == pp.product_id,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        limit: ^limit,
        offset: ^offset,
        preload: [product_prices: pp]

    Repo.all(query)
  end
end
