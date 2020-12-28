defmodule Jaang.SearchManager do
  alias Jaang.Search.{SearchTerms}

  defdelegate create_search_term(attrs), to: SearchTerms
  defdelegate delete_search_term(search_term), to: SearchTerms
  defdelegate list_popular_search_terms(store_id, limit \\ 10), to: SearchTerms
  defdelegate get_search_terms(store_id, term, limit \\ 10), to: SearchTerms
end
