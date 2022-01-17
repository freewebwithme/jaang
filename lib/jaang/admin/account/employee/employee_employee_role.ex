defmodule Jaang.Admin.Account.Employee.EmployeeEmployeeRole do
  use Ecto.Schema

  schema "employee_employee_roles" do
    belongs_to :employee, Jaang.Admin.Account.Employee.Employee
    belongs_to :employee_role, Jaang.Admin.Account.Employee.EmployeeRole

    timestamps(type: :utc_datetime)
  end
end
