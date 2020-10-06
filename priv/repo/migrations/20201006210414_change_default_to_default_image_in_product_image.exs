defmodule Jaang.Repo.Migrations.ChangeDefaultToDefaultImageInProductImage do
  use Ecto.Migration

  def change do
    alter table("product_images") do
      remove :default, :boolean
      add :defaultImage, :boolean, default: true
    end
  end
end
