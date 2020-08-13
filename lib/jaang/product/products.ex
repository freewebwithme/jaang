defmodule Jaang.Product.Products do
  @moduledoc """
   Function module for Product
  """
  alias Jaang.Product
  alias Jaang.Product.{Unit, ProductImage}
  alias Jaang.Repo
  import Ecto.Query

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
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

  def get_product(id) do
    Repo.get(Product, id)
  end

  def get_all_products(category_id) do
    query = from p in Product, where: p.category_id == ^category_id
    Repo.all(query)
  end

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
