defmodule Jaang.Repo.Migrations.ChangeDefaultImageInProductImage do
  use Ecto.Migration

  def change do
    alter table("product_images") do
      remove :defaultImage, :boolean
      add :default_image, :boolean, default: true
    end
  end
end
