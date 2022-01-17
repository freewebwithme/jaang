defmodule Jaang.Repo.Migrations.CreateEmployeeAssignedInvoicesTable do
  use Ecto.Migration

  def change do
    create table("employee_assigned_invoices") do
      add :employee_id, references(:employees)
      add :invoice_id, references(:invoices)

      timestamps(type: :timestamptz)
    end
  end
end
