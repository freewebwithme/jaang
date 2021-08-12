defmodule Jaang.Repo.Migrations.AddFinalizedFieldToOrder do
  use Ecto.Migration

  def change do
    alter table("orders") do
      add :finalized, :boolean, default: false
    end
  end
end
