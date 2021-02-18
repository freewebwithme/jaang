defmodule Jaang.Repo.Migrations.CreateEmployeeProfileTable do
  use Ecto.Migration

  def change do
    create table("employee_profiles") do
      add :first_name, :string
      add :last_name, :string
      add :phone, :string
      add :photo_url, :string

      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end
  end
end
