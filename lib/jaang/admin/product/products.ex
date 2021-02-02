defmodule Jaang.Admin.Product.Products do
  alias Jaang.Product
  alias Jaang.ProductManager
  import Ecto.Query
  alias Jaang.Repo

  @doc """
  Get all products depends on published state and by Store id
  params: published = true or false
          store_id = 1
  """
  def get_products_by_published_state(published, store_id) do
    query = from p in Product, where: p.published == ^published and p.store_id == ^store_id
    Repo.all(query)
  end
end
