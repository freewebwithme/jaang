defmodule JaangWeb.Resolvers.StoreResolver do
  alias Jaang.StoreManager

  # Store
  def get_stores(_, _, _) do
    {:ok, StoreManager.get_all_stores()}
  end

  def get_store(_, %{id: id}, _) do
    {:ok, StoreManager.get_store(id)}
  end
end
