defmodule Jaang.Product.RecipeTag do
  use Ecto.Schema
  import Ecto.Changeset

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
end
