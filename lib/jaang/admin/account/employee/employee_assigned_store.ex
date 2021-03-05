defmodule Jaang.Admin.Account.Employee.EmployeeAssignedStore do
  use Ecto.Schema

  schema "employees_assigned_stores" do
    belongs_to :employee, Jaang.Admin.Account.Employee.Employee
    belongs_to :store, Jaang.Store

    timestamps(type: :utc_datetime)
  end
end
