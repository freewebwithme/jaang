defmodule Jaang.Repo.Migrations.AddNamesToProduct do
  use Ecto.Migration

  def change do
    alter table("products") do
      add :unit_name, :string
      add :store_name, :string
      add :category_name, :string
      add :sub_category_name, :string
    end
  end
end
