defmodule JaangWeb.Schema.Employee.EmployeeInvoiceTypes do
  use Absinthe.Schema.Notation

  alias JaangWeb.Resolvers.Employee.EmployeeInvoiceResolver

  object :employee_invoice_queries do
    @desc "Get assigned invoices for employee"
    field :get_assigned_invoices, list_of(:invoice) do
      arg(:employee_id, non_null(:string))
      arg(:limit, :integer, default_value: 20)

      resolve(&EmployeeInvoiceResolver.get_assigned_invoices/3)
    end
  end
end
