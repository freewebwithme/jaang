defmodule JaangWeb.Resolvers.SearchResolver do
  alias Jaang.{AccountManager, SearchManager}

  def search_products(_, %{terms: terms, token: token, limit: limit, offset: offset}, _) do
    user = AccountManager.get_user_by_session_token(token)
    {:ok, SearchManager.search(terms, user.profile.store_id, limit, offset)}
  end

  def get_suggest_search(_, %{token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)
    terms = SearchManager.list_suggest_search_terms(user.profile.store_id)
    {:ok, terms}
  end
end
