defmodule JaangWeb.Resolvers.ProductResolver do
  alias Jaang.{ProductManager, AccountManager}

  def get_product(_, %{id: id}, _) do
    IO.puts("calling product resolver")
    {:ok, ProductManager.get_product(id)}
  end

  def get_all_products(_, %{category_id: cat_id}, _) do
    {:ok, ProductManager.get_all_products(cat_id)}
  end

  def get_related_products(
        _,
        %{product_id: product_id, limit: limit},
        _
      ) do
    products = ProductManager.get_related_products(product_id, limit)
    {:ok, products}
  end

  def get_replacement_products(_, %{product_id: product_id, limit: limit}, _) do
    IO.inspect(product_id)
    products = ProductManager.get_replacement_products(product_id, limit)
    {:ok, products}
  end

  def get_often_bought_with_products(
        _,
        %{product_id: product_id, limit: limit},
        _
      ) do
    products = ProductManager.get_often_bought_with_products(product_id, limit)
    {:ok, products}
  end

  def list_categories(_, _, _) do
    {:ok, ProductManager.list_categories()}
  end

  def get_all_sale_products(_, %{token: token, limit: limit, offset: offset}, _) do
    user = AccountManager.get_user_by_session_token(token)
    {:ok, ProductManager.get_sales_products(user.profile.store_id, limit, offset)}
  end
end
