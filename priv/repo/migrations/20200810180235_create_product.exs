defmodule Jaang.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table("products") do
      add :name, :string
      add :description, :text
      add :vendor, :string
      add :published, :boolean
      add :barcode, :string
      add :unit_name, :string
      add :store_name, :string
      add :category_name, :string
      add :sub_category_name, :string
      add :ingredients, :text
      add :directions, :text
      add :warnings, :text

      add :unit_id, references(:units, on_delete: :nothing)
      add :sub_category_id, references(:sub_categories, on_delete: :nothing)
      add :store_id, references(:stores, on_delete: :nothing)
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps(type: :timestamptz)
    end
  end
end
