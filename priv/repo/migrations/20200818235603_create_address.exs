defmodule Jaang.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table("addresses") do
      add :address_line_one, :string
      add :address_line_two, :string

      add :business_name, :string
      add :zipcode, :string
      add :city, :string
      add :state, :string
      add :instructions, :text
      add :default, :boolean, default: false
      add :recipient, :string

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end
  end
end
