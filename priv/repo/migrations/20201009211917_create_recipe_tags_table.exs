defmodule Jaang.Repo.Migrations.CreateRecipeTagsTable do
  use Ecto.Migration

  def change do
    create table("recipe_tags") do
      add :product_id, references(:products)
      add :tag_id, references(:tags)
      timestamps()
    end
  end
end
