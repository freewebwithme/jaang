defmodule Jaang.Admin.Account.Employee.EmployeeAssignedWork do
  use Ecto.Schema

  schema "employee_assigned_works" do
    belongs_to :employee, Jaang.Admin.Account.Employee.Employee
    belongs_to :assigned_work, Jaang.Admin.Account.Employee.AssignedWork

    timestamps(type: :utc_datetime)
  end
end
