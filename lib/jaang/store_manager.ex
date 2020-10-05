defmodule Jaang.StoreManager do
  alias Jaang.Product.Products
  alias Jaang.Store.Stores
  alias Jaang.Category.Categories

  # Stores
  defdelegate get_all_stores(), to: Stores
  defdelegate get_store(id), to: Stores
  defdelegate create_store(attrs), to: Stores
  defdelegate get_products_for_homescreen(limit), to: Stores

  # Products
  defdelegate create_product(attrs), to: Products
  defdelegate create_unit(attrs), to: Products
  defdelegate create_product_image(product, attrs), to: Products
  defdelegate get_product(id), to: Products
  defdelegate get_all_products(category_id), to: Products

  # Categories
  defdelegate create_category(attrs), to: Categories
  defdelegate create_subcategory(category, attrs), to: Categories
  defdelegate get_category(id), to: Categories
  defdelegate get_products_by_category(id), to: Categories
  defdelegate get_products_by_sub_category(id), to: Categories
  defdelegate get_all_categories(), to: Categories
end
