defmodule Jaang.Repo.Migrations.CreateProductImages do
  use Ecto.Migration

  def change do
    create table("product_images") do
      add :image_url, :string
      add :order, :integer, range: [1..3]

      add :product_id, references(:products, on_delete: :nothing)
      timestamps(type: :timestamptz)
    end
  end
end
