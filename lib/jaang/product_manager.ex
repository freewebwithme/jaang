defmodule Jaang.ProductManager do
  alias Jaang.Product.Products
  alias Jaang.Category.Categories

  @type t :: %Jaang.Product{}
  @type changeset :: %Ecto.Changeset{}

  @spec create_product(map) :: t
  defdelegate create_product(attrs), to: Products

  @spec update_product(t, map()) :: {:ok, t} | {:error, changeset}
  defdelegate update_product(product, attrs), to: Products

  @spec create_unit(map) :: {:ok, %Jaang.Product.Unit{}} | {:error, changeset}
  defdelegate create_unit(attrs), to: Products

  @spec create_product_image(t, map) :: {:ok, %Jaang.Product.ProductImage{}} | {:error, changeset}
  defdelegate create_product_image(product, attrs), to: Products

  @spec get_product(integer()) :: t | nil
  defdelegate get_product(id), to: Products

  @spec get_all_products(integer()) :: list(t)
  defdelegate get_all_products(category_id), to: Products

  @spec get_sales_products(integer(), integer(), integer()) :: list(t)
  defdelegate get_sales_products(store_id, limit, offset), to: Products

  # Related products
  @spec get_related_products(integer(), integer()) :: list(t)
  defdelegate get_related_products(product_id, limit), to: Products

  @spec get_often_bought_with_products(integer(), integer()) :: list(t)
  defdelegate get_often_bought_with_products(product_id, limit), to: Products

  # Get replacement products
  @spec get_replacement_products(integer(), integer()) :: list(t)
  defdelegate get_replacement_products(product_id, limit), to: Products
  # Categories
  defdelegate list_categories(), to: Categories
end
