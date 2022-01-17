defmodule Jaang.Repo.Migrations.CreateProfile do
  use Ecto.Migration

  def change do
    create table("profiles") do
      add :first_name, :string
      add :last_name, :string
      add :phone, :string

      add :photo_url, :string

      add :store_id, :id, default: nil
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end
  end
end
