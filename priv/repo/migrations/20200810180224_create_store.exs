defmodule Jaang.Repo.Migrations.CreateStore do
  use Ecto.Migration

  def change do
    create table("stores") do
      add :name, :string
      add :description, :string
      add :price_info, :text
      add :available_hours, :string

      timestamps()
    end
  end
end
