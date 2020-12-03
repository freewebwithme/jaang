defmodule Jaang.Repo.Migrations.CreateDistanceTable do
  use Ecto.Migration

  def change do
    create table("distances") do
      add :address_id, references(:addresses, on_delete: :delete_all)
      add :store_distances, :map
    end
  end
end
