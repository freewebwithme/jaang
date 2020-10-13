defmodule Jaang.Repo.Migrations.AddOrderFieldToProductImages do
  use Ecto.Migration

  def change do
    alter table("product_images") do
      remove :default_image
      add :order, :integer, range: [1..3]
    end
  end
end
