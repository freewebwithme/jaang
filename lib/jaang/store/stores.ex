defmodule Jaang.Store.Stores do
  @moduledoc """
  Function module for Store
  """
  alias Jaang.Repo
  alias Jaang.Store

  def create_store(attrs) do
    %Store{}
    |> Store.changeset(attrs)
    |> Repo.insert()
  end

  def get_store(id) do
    Repo.get(Store, id)
  end

  def get_all_stores() do
    Repo.all(Store)
  end

  # TODO: Create function that returns
  # first 10 items from each category for front page
end
