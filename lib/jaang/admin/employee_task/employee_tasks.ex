defmodule Jaang.Admin.EmployeeTask.EmployeeTasks do
  alias Jaang.Repo
  alias Jaang.Admin.EmployeeTask
  alias Jaang.Invoice
  import Ecto.Query

  def create_employee_task(%{} = attrs) do
    %EmployeeTask{}
    |> EmployeeTask.changeset(attrs)
    |> Repo.insert()
  end

  def create_employee_task(%Invoice{} = invoice, employee_id, task_type, task_status) do
    [order] = invoice.orders
    line_items_maps = Enum.map(order.line_items, &Map.from_struct/1)

    attrs = %{
      task_type: task_type,
      task_status: task_status,
      start_datetime: Timex.now(),
      invoice_id: invoice.id,
      order_id: order.id,
      employee_id: employee_id,
      line_items: line_items_maps
    }

    create_employee_task(attrs)
  end

  def get_employee_task(employee_id) do
    Repo.get_by(EmployeeTask, employee_id: employee_id)
  end

  def get_in_progress_employee_task(employee_id) do
    query =
      from et in EmployeeTask,
        where:
          et.employee_id == ^employee_id and et.task_type == :shopping and
            et.task_status == :in_progress

    Repo.one(query)
  end

  def update_employee_task(%EmployeeTask{} = employee_task, attrs) do
    employee_task
    |> EmployeeTask.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  This function updates line_items' status in EmployeeTask
  This function will be used when shopper(in client app) fulfills orders
  """
  def update_employee_task_line_item_status(employee_task_id, line_item_id, status) do
    employee_task = Repo.get_by(EmployeeTask, id: employee_task_id)
    existing_line_items = employee_task.line_items

    # exclude selected line item from existing line_items then convert to map
    existing_line_items_map =
      existing_line_items
      |> Enum.filter(fn line_item -> line_item.id != line_item_id end)
      |> Enum.map(&Map.from_struct/1)

    # Get selected line_item
    [line_item] = Enum.filter(existing_line_items, &(&1.id == line_item_id))
    # Convert to map and update status value
    line_item_map = line_item |> Map.from_struct() |> Map.put(:status, status)
    employee_task_attrs = %{line_items: [line_item_map | existing_line_items_map]}
    update_employee_task(employee_task, employee_task_attrs)
  end
end
