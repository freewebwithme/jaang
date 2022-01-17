defmodule Jaang.Repo.Migrations.CreateEmployeeRoleTable do
  use Ecto.Migration

  def change do
    create table("employee_roles") do
      add :name, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(:employee_roles, :name)
  end
end
