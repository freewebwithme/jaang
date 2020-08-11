defmodule Jaang.Repo.Migrations.CreateProductImages do
  use Ecto.Migration

  def change do
    create table("product_images") do
      add :image_url, :string
      add :default, :boolean, default: false

      add :product_id, references(:products, on_delete: :nothing)
      timestamps()
    end
  end
end
