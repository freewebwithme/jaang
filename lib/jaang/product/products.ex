defmodule Jaang.Product.Products do
  @moduledoc """
   Function module for Product
  """
  alias Jaang.Product
  alias Jaang.Repo
  import Ecto.Query

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def get_product(id) do
    Repo.get(Product, id)
  end

  def get_all_products(category_id) do
    query = from p in Product, where: p.category_id == ^category_id
    Repo.all(query)
  end
end
