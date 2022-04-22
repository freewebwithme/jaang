defmodule Jaang.ProductManager do
  alias Jaang.Product.Products
  alias Jaang.Category.Categories
  alias Jaang.Product


  @spec create_product(map) :: Product.t()
  defdelegate create_product(attrs), to: Products

  @spec update_product(Product.t(), map()) :: {:ok, Product.t() } | {:error, Ecto.Changeset.t()}
  defdelegate update_product(product, attrs), to: Products

  @spec create_unit(map) :: {:ok, Jaang.Product.Unit.t() } | {:error, Ecto.Changeset.t()}
  defdelegate create_unit(attrs), to: Products

  @spec create_product_image(Product.t(), map) :: {:ok, Jaang.Product.ProductImage.t() } | {:error, Ecto.Changeset.t()}
  defdelegate create_product_image(product, attrs), to: Products

  @spec get_product(integer()) :: Product.t() | nil
  defdelegate get_product(id), to: Products

  @spec get_all_products(integer()) :: list(Product.t())
  defdelegate get_all_products(category_id), to: Products

  @spec get_sales_products(integer(), integer(), integer()) :: list(Product.t())
  defdelegate get_sales_products(store_id, limit, offset), to: Products

  # Related products
  @spec get_related_products(integer(), integer()) :: list(Product.t())
  defdelegate get_related_products(product_id, limit), to: Products

  @spec get_often_bought_with_products(integer(), integer()) :: list(Product.t())
  defdelegate get_often_bought_with_products(product_id, limit), to: Products

  # Get replacement products
  @spec get_replacement_products(integer(), integer()) :: list(Product.t())
  defdelegate get_replacement_products(product_id, limit), to: Products
  # Categories
  defdelegate list_categories(), to: Categories
end
