defmodule Jaang.Search.SearchTerms do
  alias Jaang.Search.SearchTerm
  alias Jaang.Repo
  import Ecto.Query

  @doc """
  Check if term is already exist
  """
  def get_search_term(store_id, term) do
    query = from st in SearchTerm, where: st.store_id == ^store_id and st.term == ^term
    Repo.one(query)
  end

  def get_search_terms(store_id, term, limit \\ 10) do
    pattern = "%#{term}%"

    query =
      from st in SearchTerm,
        where:
          st.store_id == ^store_id and
            ilike(st.name, ^pattern),
        limit: ^limit

    Repo.all(query)
  end

  def create_search_term(attrs \\ %{}) do
    %SearchTerm{}
    |> SearchTerm.changeset(attrs)
    |> Repo.insert()
  end

  def update_search_term(%SearchTerm{} = search_term, attrs) do
    search_term
    |> SearchTerm.changeset(attrs)
    |> Repo.update()
  end

  def delete_search_term(%SearchTerm{} = search_term) do
    Repo.delete(search_term)
  end

  def list_suggest_search_terms(store_id, limit \\ 10) do
    query =
      from st in SearchTerm,
        where: st.store_id == ^store_id,
        order_by: [desc: st.counter],
        limit: ^limit

    Repo.all(query)
  end
end
