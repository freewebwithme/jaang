defmodule Jaang.Admin.Store.Stores do
  alias Jaang.{Store, Repo}
  alias Jaang.Checkout.Order
  import Ecto.Query

  def get_store_with_products() do
    Repo.all(Store) |> Repo.preload(:products)
  end

  def get_store(store_id) do
    Repo.get_by(Store, id: store_id) |> Repo.preload(:products)
  end

  def get_store_with_employees(store_id) do
    Repo.get_by(Store, id: store_id) |> Repo.preload(employees: :roles)
  end

  @doc """
  Get all orders
  """
  def get_all_orders_for_store(store_id) do
    query = from o in Order, where: o.store_id == ^store_id
    Repo.all(query)
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
