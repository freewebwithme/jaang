defmodule JaangWeb.Resolvers.ProductResolver do
  alias Jaang.StoreManager

  def get_product(_, %{id: id}, _) do
    IO.puts("calling product resolver")
    {:ok, StoreManager.get_product(id)}
  end

  def get_all_products(_, %{category_id: cat_id}, _) do
    {:ok, StoreManager.get_all_products(cat_id)}
  end
end
