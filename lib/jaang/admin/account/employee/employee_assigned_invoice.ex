defmodule Jaang.Admin.Account.Employee.EmployeeAssignedInvoice do
  use Ecto.Schema

  schema "employee_assigned_invoices" do
    belongs_to :employee, Jaang.Admin.Account.Employee.Employee
    belongs_to :invoice, Jaang.Invoice

    timestamps(type: :utc_datetime)
  end
end
