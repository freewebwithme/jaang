defmodule Jaang.Repo.Migrations.AddUnitIdToProduct do
  use Ecto.Migration

  def change do
    alter table("products") do
      add :unit_id, references(:units, on_delete: :nothing)
    end
  end
end
