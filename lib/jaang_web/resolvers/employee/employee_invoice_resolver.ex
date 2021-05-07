defmodule JaangWeb.Resolvers.Employee.EmployeeInvoiceResolver do
  alias Jaang.Admin.Invoice.Invoices

  def get_assigned_invoices(_, %{employee_id: employee_id, limit: limit}, _) do
    invoices = Invoices.get_assigned_invoices(employee_id, limit)
    {:ok, invoices}
  end
end
