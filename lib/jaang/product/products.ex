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

  @type t :: %Product{}
  @type changeset :: %Ecto.Changeset{}

  def create_product_for_seeds(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @spec create_product(map) :: t
  def create_product(attrs) do
    {:ok, product} =
      %Product{}
      |> Product.changeset(attrs)
      |> Repo.insert()

    # Create market price with product price
    MarketPrice.create_market_price_with_product_price(product.id, attrs)
    product
  end

  @spec create_unit(map) :: {:ok, %Unit{}} | {:error, changeset}
  def create_unit(attrs) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  @spec create_product_image(t, map) :: {:ok, %ProductImage{}} | {:error, changeset}
  def create_product_image(product, attrs) do
    attrs = Map.put(attrs, :product_id, product.id)

    %ProductImage{}
    |> ProductImage.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_product(t, map()) :: {:ok, t} | {:error, changeset}
  def update_product(product, attrs) do
    IO.puts("Inspecting product changeset")
    changeset = Product.changeset(product, attrs)
    IO.inspect(changeset)

    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Get product along with product price manually loading
  """
  @spec get_product(integer()) :: t | nil
  def get_product(id) do
    #  query =
    #    from p in Product, where: p.id == ^id and p.published == true, preload: :product_images

    #  product = Repo.one(query)
    #  product_price = ProductPrice.get_product_price(id)

    #  cond do
    #    is_nil(product_price) ->
    #      Map.put(product, :produ ct_prices, [])

    #    true ->
    #      Map.put(product, :product_prices, [product_price])
    #  end
    query =
      from p in Product,
        where: p.id == ^id and p.published == true,
        join: pp in assoc(p, :product_prices),
        on: pp.product_id == p.id,
        where: fragment("now() between ? and ?", pp.start_date, pp.end_date),
        join: mp in assoc(p, :market_prices),
        on: mp.product_id == p.id,
        where: fragment("now() between ? and ?", mp.start_date, mp.end_date),
        join: pi in assoc(p, :product_images),
        on: pi.product_id == p.id,
        preload: [product_images: pi, product_prices: pp, market_prices: mp]

    Repo.one(query)
  end

  @spec get_sales_products(integer(), integer(), integer()) :: list(t)
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

  @spec get_all_products(integer()) :: list(t)
  def get_all_products(category_id) do
    query = from p in Product, where: p.category_id == ^category_id and p.published == true
    Repo.all(query)
  end

  @doc """
  Get related products
  """
  @spec get_related_products(integer(), integer()) :: list(t)
  def get_related_products(product_id, limit) do
    product = Repo.get_by(Product, id: product_id) |> Repo.preload(:tags)
    tag_ids = Enum.map(product.tags, & &1.id)

    # get all products that has same tag with requested product
    products =
      get_product_ids_using_tag_ids(:product_tag, product_id, tag_ids)
      |> get_products_by_ids(product.store_id)

    # Filter by category name
    same_category_products = Enum.filter(products, &(&1.category_name == product.category_name))

    # Filter by product name
    requested_product_name = String.split(product.name)

    same_product_name =
      Enum.filter(same_category_products, fn product ->
        String.contains?(product.name, requested_product_name)
      end)

    # Flatten merged list and return only 5 products
    List.flatten([same_product_name | same_category_products]) |> Enum.uniq() |> Enum.take(limit)
  end

  @doc """
  Get often bought with products
  If products share same recipe tags,
  I guess it is often bought with products
  """
  @spec get_often_bought_with_products(integer(), integer()) :: list(t)
  def get_often_bought_with_products(product_id, limit) do
    product = Repo.get_by(Product, id: product_id) |> Repo.preload(:recipe_tags)
    tag_ids = Enum.map(product.recipe_tags, & &1.id)

    # get all products that has same tag with requested product
    products =
      get_product_ids_using_tag_ids(:recipe_tag, product_id, tag_ids)
      |> get_products_by_ids(product.store_id)

    # Filter by category name
    same_category_products = Enum.filter(products, &(&1.category_name == product.category_name))

    # Filter by product name
    requested_product_name = String.split(product.name)

    same_product_name =
      Enum.filter(same_category_products, fn product ->
        String.contains?(product.name, requested_product_name)
      end)

    # Flatten merged list and return only 5 products
    List.flatten([same_product_name | same_category_products]) |> Enum.uniq() |> Enum.take(limit)
  end

  @doc """
  Get all products from list of Product ids(ex: [3, 5, 10, 22])
  Product images are loaded with Dataloader in Schema.ex but
  preload ProductPrice manually because I need to filter it
  """
  @spec get_products_by_ids(list(integer()), integer()) :: list(t)
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

  @spec get_replacement_products(integer(), integer()) :: list(t)
  def get_replacement_products(product_id, limit) do
    product = Repo.get_by(Product, id: product_id) |> Repo.preload(:tags)
    tag_ids = Enum.map(product.tags, & &1.id)

    # get all products that has same tag with requested product
    products =
      get_product_ids_using_tag_ids(:product_tag, product_id, tag_ids)
      |> get_products_by_ids(product.store_id)

    # Filter by category name
    same_category_products = Enum.filter(products, &(&1.category_name == product.category_name))

    # Filter by product name
    requested_product_name = String.split(product.name)

    same_product_name =
      Enum.filter(same_category_products, fn product ->
        String.contains?(product.name, requested_product_name)
      end)

    # Flatten merged list and return only 5 products
    List.flatten([same_product_name | same_category_products]) |> Enum.uniq() |> Enum.take(limit)
  end

  @doc """
  Get product ids using tag id
  returns [3, 4, 5, 6, 10, 30]
  This function is used for replacement products
  """
  @spec get_product_ids_using_tag_ids(:product_tag, integer(), list(integer())) :: list(integer())
  def get_product_ids_using_tag_ids(:product_tag, product_id, tag_ids) do
    query =
      from pt in ProductTags,
        where: pt.tag_id in ^tag_ids and pt.product_id != ^product_id,
        select: pt.product_id

    Repo.all(query)
  end

  @spec get_product_ids_using_tag_ids(:recipe_tag, integer(), list(integer())) :: list(integer())
  def get_product_ids_using_tag_ids(:recipe_tag, product_id, tag_ids) do
    query =
      from prt in ProductRecipeTags,
        where: prt.recipe_tag_id in ^tag_ids and prt.product_id != ^product_id,
        select: prt.product_id

    Repo.all(query)
  end

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
