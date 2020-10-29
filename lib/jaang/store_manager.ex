defmodule Jaang.StoreManager do
  alias Jaang.Store.Stores
  alias Jaang.Category.Categories

  # Stores
  defdelegate get_all_stores(), to: Stores
  defdelegate get_store(id), to: Stores
  defdelegate create_store(attrs), to: Stores
  defdelegate get_products_for_homescreen(limit, store_id), to: Stores

  # Categories
  defdelegate create_category(attrs), to: Categories
  defdelegate create_subcategory(category, attrs), to: Categories
  defdelegate get_category(id), to: Categories
  defdelegate get_products_by_category(category_id, store_id), to: Categories
  defdelegate get_products_by_sub_category(category_id, store_id, limit), to: Categories

  defdelegate get_products_by_sub_category_name(category_name, store_id, limit, offset),
    to: Categories

  defdelegate get_all_categories(), to: Categories
end
