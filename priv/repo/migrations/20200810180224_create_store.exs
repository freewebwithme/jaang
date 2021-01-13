defmodule Jaang.Repo.Migrations.CreateStore do
  use Ecto.Migration

  def change do
    create table("stores") do
      add :name, :string
      add :store_logo, :string
      add :description, :string
      add :price_info, :text
      add :available_hours, :string
      add :address, :string
      add :phone_number, :string

      timestamps(type: :timestamptz)
    end
  end
end
