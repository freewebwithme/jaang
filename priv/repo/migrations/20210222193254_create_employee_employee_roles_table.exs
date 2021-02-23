defmodule Jaang.Repo.Migrations.CreateEmployeeEmployeeRolesTable do
  use Ecto.Migration

  def change do
    create table("employee_employee_roles") do
      add :employee_role_id, references(:employee_roles)
      add :employee_id, references(:employees)

      timestamps(type: :timestamptz)
    end
  end
end
