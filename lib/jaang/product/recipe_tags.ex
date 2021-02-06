defmodule Jaang.Product.RecipeTag do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Jaang.Repo
  alias Jaang.Product.RecipeTag

  schema "recipe_tags" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe_tag, attrs) do
    recipe_tag
    |> cast(attrs, [:name])
    |> unique_constraint(:name)
    |> validate_required([:name])
  end

  def parse_recipe_tags(attrs) do
    (Map.get(attrs, :recipe_tags) || Map.get(attrs, "recipe_tags") || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all_recipe_tags()
  end

  # put_assoc is used when I have already an associated struct so
  # before use put_assoc, do create a database record
  defp insert_and_get_all_recipe_tags([]), do: []

  defp insert_and_get_all_recipe_tags(names) do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second)
    maps = Enum.map(names, &%{name: &1, inserted_at: timestamp, updated_at: timestamp})
    Repo.insert_all(RecipeTag, maps, on_conflict: :nothing)
    Repo.all(from(t in RecipeTag, where: t.name in ^names))
  end
end
