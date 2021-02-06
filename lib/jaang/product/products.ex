defmodule Jaang.Product.Products do
  @moduledoc """
   Function module for Product
  """
  alias Jaang.{Product, Repo}

  alias Jaang.Product.{
    Unit,
    ProductImage,
    ProductTags,
    ProductRecipeTags,
    MarketPrice
  }

  import Ecto.Query

  def create_product_for_seeds(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def create_product(attrs) do
    {:ok, product} =
      %Product{}
      |> Product.changeset(attrs)
      |> Repo.insert()

    # Create market price with product price
    MarketPrice.create_market_price_with_product_price(product.id, attrs)
  end

  def create_unit(attrs) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  def create_product_image(product, attrs) do
    attrs = Map.put(attrs, :product_id, product.id)

    %ProductImage{}
    |> ProductImage.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Get product along with product price manually loading
  """
  def get_product(id) do
    #  query =
    #    from p in Product, where: p.id == ^id and p.published == true, preload: :product_images

    #  product = Repo.one(query)
    #  product_price = ProductPrice.get_product_price(id)

    #  cond do
    #    is_nil(product_price) ->
    #      Map.put(product, :product_prices, [])

    #    true ->
    #      Map.put(product, :product_prices, [product_price])
    #  end
    query =
      from p in Product,
        where: p.id == ^id and p.published == true,
        join: pp in assoc(p, :product_prices),
        on: pp.product_id == p.id,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        join: pi in assoc(p, :product_images),
        on: pi.product_id == p.id,
        preload: [product_images: pi, product_prices: pp]

    Repo.one(query)
  end

  def get_sales_products(store_id, limit, offset) do
    query = from p in Product, where: p.store_id == ^store_id, limit: ^limit, offset: ^offset

    join_query =
      from p in query,
        join: pp in assoc(p, :product_prices),
        on: pp.product_id == p.id,
        where: pp.on_sale == true,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        preload: [product_prices: pp]

    # preload: [:product_images] preloading from Dataloader in schema.ex

    Repo.all(join_query)
  end

  def get_all_products(category_id) do
    query = from p in Product, where: p.category_id == ^category_id and p.published == true
    Repo.all(query)
  end

  @doc """
  Get related products
  """
  def get_related_products(product_id, tag_id, limit, store_id) do
    get_product_ids_using_tags_id(:product_tag, product_id, tag_id, limit)
    |> get_products_by_ids(store_id)
  end

  @doc """
  Get often bought with products
  If products share same recipe tags,
  I guess it is often bought with products
  """
  def get_often_bought_with_products(product_id, tag_id, limit, store_id) do
    get_product_ids_using_tags_id(:recipe_tag, product_id, tag_id, limit)
    |> get_products_by_ids(store_id)
  end

  @doc """
  Get product ids using tag id
  returns [3, 4, 5, 6, 10, 30]
  """
  def get_product_ids_using_tags_id(:product_tag, product_id, tag_id, limit) do
    query =
      from pt in ProductTags,
        where: pt.tag_id == ^tag_id and pt.product_id != ^product_id,
        limit: ^limit,
        select: pt.product_id

    Repo.all(query)
  end

  def get_product_ids_using_tags_id(:recipe_tag, product_id, tag_id, limit) do
    query =
      from rt in ProductRecipeTags,
        where: rt.recipe_tag_id == ^tag_id and rt.product_id != ^product_id,
        limit: ^limit,
        select: rt.product_id

    Repo.all(query)
  end

  @doc """
  Get all products from list of Product ids(ex: [3, 5, 10, 22])
  Product images are loaded with Dataloader in Schema.ex but
  preload ProductPrice manually because I need to filter it
  """
  def get_products_by_ids(ids, store_id) do
    query =
      from p in Product,
        where: p.id in ^ids and p.store_id == ^store_id and p.published == true,
        join: pp in assoc(p, :product_prices),
        on: pp.product_id == p.id,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        preload: [product_prices: pp]

    Repo.all(query)
  end

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
