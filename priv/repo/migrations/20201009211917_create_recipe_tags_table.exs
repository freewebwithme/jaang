defmodule Jaang.Repo.Migrations.CreateRecipeTagsTable do
  use Ecto.Migration

  def change do
    create table("recipe_tags") do
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create unique_index("recipe_tags", [:name])
  end
end
