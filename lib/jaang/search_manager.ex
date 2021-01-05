defmodule Jaang.SearchManager do
  alias Jaang.Search.{SearchTerms}
  alias Jaang.Search

  defdelegate search(term, store_id, limit, offset), to: Search

  defdelegate get_search_term(store_id, term), to: SearchTerms
  defdelegate create_search_term(attrs), to: SearchTerms
  defdelegate update_search_term(search_term, attrs), to: SearchTerms
  defdelegate delete_search_term(search_term), to: SearchTerms
  defdelegate list_suggest_search_terms(store_id, limit \\ 10), to: SearchTerms
  defdelegate get_search_terms(store_id, term, limit \\ 10), to: SearchTerms
end
