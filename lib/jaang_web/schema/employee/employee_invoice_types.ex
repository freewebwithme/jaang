defmodule JaangWeb.Schema.Employee.EmployeeOrderTypes do
  use Absinthe.Schema.Notation

  alias JaangWeb.Resolvers.Employee.EmployeeOrderResolver

  object :employee_order_queries do
    @desc "Get assigned orders for employee"
    field :get_assigned_orders, list_of(:order) do
      arg(:employee_id, non_null(:string))
      arg(:limit, :integer, default_value: 20)

      resolve(&EmployeeOrderResolver.get_assigned_orders/3)
    end
  end
end
