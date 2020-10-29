defmodule JaangWeb.Resolvers.CategoryResolver do
  alias Jaang.StoreManager

  def get_products_by_category(_, %{category_id: category_id, store_id: store_id}, _) do
    # category_id = String.to_integer(id)
    {:ok, StoreManager.get_products_by_category(category_id, store_id)}
  end

  def get_products_by_subcategory(
        _,
        %{category_id: category_id, store_id: store_id, limit: limit},
        _
      ) do
    {:ok, StoreManager.get_products_by_sub_category(category_id, store_id, limit)}
  end

  def get_products_by_subcategory_name(
        _,
        %{category_name: category_name, store_id: store_id, limit: limit, offset: offset},
        _
      ) do
    {:ok, StoreManager.get_products_by_sub_category_name(category_name, store_id, limit, offset)}
  end
end
