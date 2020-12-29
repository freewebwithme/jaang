defmodule Jaang.ProductManager do
  alias Jaang.Product.Products
  alias Jaang.Category.Categories

  defdelegate create_product(attrs), to: Products
  defdelegate create_unit(attrs), to: Products
  defdelegate create_product_image(product, attrs), to: Products
  defdelegate get_product(id), to: Products
  defdelegate get_all_products(category_id), to: Products

  # Related products
  defdelegate get_related_products(product_id, tag_id, limit, store_id), to: Products
  defdelegate get_often_bought_with_products(product_id, tag_id, limit, store_id), to: Products

  # Categories
  defdelegate list_categories(), to: Categories
end
