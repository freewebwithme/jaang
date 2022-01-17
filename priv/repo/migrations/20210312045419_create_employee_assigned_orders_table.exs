defmodule Jaang.Repo.Migrations.CreateEmployeeAssignedOrdersTable do
  use Ecto.Migration

  def change do
    create table("employee_assigned_orders") do
      add :employee_id, references(:employees)
      add :order_id, references(:orders)

      timestamps(type: :timestamptz)
    end

    alter table("orders") do
      remove :employee_id
    end
  end
end
