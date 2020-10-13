defmodule Jaang.Repo.Migrations.AddUniqueIndexToTagTable do
  use Ecto.Migration

  def change do
    alter table("recipe_tags") do
      remove :product_id, references(:products)
      remove :tag_id, references(:tags)

      add :name, :string
    end

    create table("product_recipe_tags") do
      add :product_id, references(:products)
      add :recipe_tag_id, references(:recipe_tags)

      timestamps()
    end

    create unique_index("tags", [:name])
    create unique_index("recipe_tags", [:name])
  end
end
