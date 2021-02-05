defmodule Jaang.Repo.Migrations.RemoveUnitIdFromProductTable do
  use Ecto.Migration

  def change do
    alter table("products") do
      remove :unit_id, :id
    end
  end
end
