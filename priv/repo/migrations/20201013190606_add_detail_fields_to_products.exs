defmodule Jaang.Repo.Migrations.AddDetailFieldsToProducts do
  use Ecto.Migration

  def change do
    alter table("products") do
      add :ingredients, :text
      add :directions, :text
      add :warnings, :text
    end
  end
end
