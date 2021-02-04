defmodule Jaang.Admin.Store.Stores do
  alias Jaang.{Store, Repo}

  def get_store_with_products() do
    Repo.all(Store) |> Repo.preload(:products)
  end

  def get_store(store_id) do
    Repo.get_by(Store, id: store_id) |> Repo.preload(:products)
  end

  @doc """
  This function will be called in admin home screen
  to get information about stores to display store list in
  navigation menu
  """
  def list_stores() do
    Repo.all(Store)
  end
end
