defmodule JaangWeb.Resolvers.StoreResolver do
  alias Jaang.StoreManager
  alias Jaang.AccountManager

  # Store
  def get_stores(_, _, _) do
    {:ok, StoreManager.get_all_stores()}
  end

  def get_store(_, %{id: id}, _) do
    {:ok, StoreManager.get_store(id)}
  end

  def change_store(_, %{token: token, store_id: store_id}, _) do
    user = AccountManager.get_user_by_session_token(token)
    AccountManager.update_profile(user, %{store_id: String.to_integer(store_id)})

    {:ok, %{user: user, token: token, expired: false}}
  end

  def get_products_for_homescreen(_, %{limit: limit, store_id: store_id}, _) do
    categories = StoreManager.get_products_for_homescreen(limit, store_id)
    # IO.inspect(categories)
    {:ok, categories}
  end

  def get_delivery_datetime(_, _, _) do
    {:ok, StoreManager.get_available_delivery_datetime()}
  end
end
