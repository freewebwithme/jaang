defmodule Jaang.Search.SearchTerm do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_terms" do
    field :term, :string
    field :counter, :integer

    belongs_to :store, Jaang.Store

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Search.SearchTerm{} = search_term, attrs) do
    search_term
    |> cast(attrs, [:term, :counter, :store_id])
    |> unique_constraint(:term)
    |> validate_length(:term, min: 3)
  end
end
