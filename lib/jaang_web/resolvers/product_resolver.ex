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
        %{product_id: product_id, tag_id: tag_id, limit: limit, store_id: store_id},
        _
      ) do
    products = ProductManager.get_related_products(product_id, tag_id, limit, store_id)
    {:ok, products}
  end

  def get_often_bought_with_products(
        _,
        %{product_id: product_id, tag_id: tag_id, limit: limit, store_id: store_id},
        _
      ) do
    products = ProductManager.get_often_bought_with_products(product_id, tag_id, limit, store_id)
    {:ok, products}
  end

  def search_products(_, %{terms: terms, token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)
    IO.inspect(user.profile.store_id)
    {:ok, ProductManager.search(terms, user.profile.store_id)}
  end
end
