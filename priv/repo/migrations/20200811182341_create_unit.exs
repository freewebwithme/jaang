defmodule Jaang.Repo.Migrations.CreateUnit do
  use Ecto.Migration

  def change do
    create table("units") do
      add :name, :string

      timestamps()
    end

    create unique_index("units", [:name])
  end
end
