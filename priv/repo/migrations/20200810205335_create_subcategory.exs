defmodule Jaang.Repo.Migrations.CreateSubcategory do
  use Ecto.Migration

  def change do
    create table("sub_categories") do
      add :name, :string

      add :category_id, references(:categories, on_delete: :nothing)
    end
  end
end
