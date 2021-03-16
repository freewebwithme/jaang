defmodule Jaang.Admin.EmployeeTask.EmployeeTasks do
  alias Jaang.Repo
  alias Jaang.Admin.EmployeeTask
  alias Jaang.Invoice

  def create_employee_task(%{} = attrs) do
    %EmployeeTask{}
    |> EmployeeTask.changeset(attrs)
    |> Repo.insert()
  end

  def create_employee_task(%Invoice{} = invoice, employee_id, task_type, task_status) do
    [order] = invoice.orders

    attrs = %{
      task_type: task_type,
      task_status: task_status,
      start_datetime: Timex.now(),
      invoice_id: invoice.id,
      order_id: order.id,
      employee_id: employee_id
    }

    create_employee_task(attrs)
  end
end
