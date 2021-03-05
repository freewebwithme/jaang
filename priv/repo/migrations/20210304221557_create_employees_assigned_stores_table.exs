defmodule Jaang.Repo.Migrations.CreateEmployeesAssignedStoresTable do
  use Ecto.Migration

  def change do
    create table("employees_assigned_stores") do
      add :employee_id, references(:employees)
      add :store_id, references(:stores)

      timestamps(type: :timestamptz)
    end
  end
end
