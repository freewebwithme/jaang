defmodule JaangWeb.Resolvers.Employee.EmployeeOrderResolver do
  alias Jaang.Admin.Order.Orders

  def get_assigned_orders(_, %{employee_id: employee_id, limit: limit}, _) do
    orders = Orders.get_assigned_orders(employee_id, limit)
    {:ok, orders}
  end
end
