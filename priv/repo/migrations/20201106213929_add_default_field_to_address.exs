defmodule Jaang.Repo.Migrations.AddDefaultFieldToAddress do
  use Ecto.Migration

  def change do
    alter table("addresses") do
      add :default, :boolean, default: false
    end
  end
end
