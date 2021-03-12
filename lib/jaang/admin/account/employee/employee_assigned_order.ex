defmodule Jaang.Admin.Account.Employee.EmployeeAssignedOrder do
  use Ecto.Schema

  schema "employee_assigned_orders" do
    belongs_to :employee, Jaang.Admin.Account.Employee.Employee
    belongs_to :order, Jaang.Checkout.Order

    timestamps(type: :utc_datetime)
  end
end
