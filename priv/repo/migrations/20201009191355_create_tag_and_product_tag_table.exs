defmodule Jaang.Repo.Migrations.CreateTagAndProductTagTable do
  use Ecto.Migration

  def change do
    create table("tags") do
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create unique_index("tags", [:name])

    create table("product_tags") do
      add :product_id, references(:products)
      add :tag_id, references(:tags)

      timestamps(type: :timestamptz)
    end
  end
end
