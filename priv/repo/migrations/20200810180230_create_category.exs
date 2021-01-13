defmodule Jaang.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table("categories") do
      add :name, :string
      add :description, :text

      timestamps(type: :timestamptz)
    end
  end
end
