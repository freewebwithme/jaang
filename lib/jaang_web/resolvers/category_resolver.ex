defmodule JaangWeb.Resolvers.CategoryResolver do
  alias Jaang.StoreManager

  def get_products_by_category(_, %{id: category_id}, _) do
    # category_id = String.to_integer(id)
    {:ok, StoreManager.get_products_by_category(category_id)}
  end

  def get_products_by_subcategory(_, %{id: id}, _) do
    {:ok, StoreManager.get_products_by_sub_category(id)}
  end
end
