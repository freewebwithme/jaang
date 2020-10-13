defmodule Jaang.Repo.Migrations.CreateTagAndProductTagTable do
  use Ecto.Migration

  def change do
    create table("tags") do
      add :name, :string

      timestamps()
    end

    create table("product_tags") do
      add :product_id, references(:products)
      add :tag_id, references(:tags)
      timestamps()
    end
  end
end
