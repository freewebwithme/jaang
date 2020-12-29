defmodule Jaang.Search do
  alias Jaang.SearchManager
  alias Jaang.Product
  alias Jaang.Search.SearchTerm
  import Ecto.Query
  alias Jaang.Repo

  @doc """
  Search product in selected store
  TODO: Improve search function using postgresql full text search
  """
  def search(term, store_id) when is_binary(term) do
    # In case of multiple search term provided,
    # split term by space

    search_terms =
      term
      |> String.replace(~r/[,.!@#$%^&*(){}]/, "")
      |> String.split(" ")

    # Save new search terms
    Enum.map(search_terms, fn term ->
      case SearchManager.get_search_term(store_id, term) do
        %SearchTerm{counter: counter} = search_term ->
          # Update search terms
          counter = counter + 1
          SearchManager.update_search_term(search_term, %{counter: counter})

        _ ->
          SearchManager.create_search_term(%{term: term, store_id: store_id, counter: 1})
      end
    end)

    # Get first search term
    [first_term] = Enum.slice(search_terms, 0, 1)
    rest_terms = Enum.slice(search_terms, 1, 100)

    first_pattern = "%#{first_term}%"

    query =
      from p in Product, where: p.store_id == ^store_id, where: ilike(p.name, ^first_pattern)

    Enum.reduce(rest_terms, query, fn search_term, query ->
      pattern = "%#{search_term}%"
      from p in query, or_where: ilike(p.name, ^pattern)
    end)
    |> Repo.all()
  end

  def search(_term, _store_id), do: []
end
