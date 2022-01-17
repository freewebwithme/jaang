defmodule Jaang.Repo.Migrations.CreateProductRecipeTags do
  use Ecto.Migration

  def change do
    create table("product_recipe_tags") do
      add :product_id, references(:products)
      add :recipe_tag_id, references(:recipe_tags)

      timestamps(type: :timestamptz)
    end
  end
end
