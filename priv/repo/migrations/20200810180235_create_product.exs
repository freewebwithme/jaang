defmodule Jaang.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table("products") do
      add :name, :string
      add :description, :text
      add :regular_price, :integer
      add :sale_price, :integer
      add :vendor, :string
      add :published, :boolean
      add :barcode, :string

      add :store_id, references(:stores, on_delete: :nothing)
      add :category_id, references(:categories, on_delete: :nothing)
    end
  end
end
