defmodule Jaang.Repo.Migrations.AddSubCategoryInProduct do
  use Ecto.Migration

  def change do
    alter table("products") do
      add :sub_category_id, references(:sub_categories, on_delete: :nothing)
    end
  end
end
