defmodule Jaang.Repo.Migrations.AddIndexToEmployeeEmployeeRolesTable do
  use Ecto.Migration

  def change do
    create index("employee_employee_roles", :employee_role_id)
    create index("employee_employee_roles", :employee_id)

    create index("employee_assigned_invoices", :employee_id)
    create index("employee_assigned_invoices", :invoice_id)
  end
end
