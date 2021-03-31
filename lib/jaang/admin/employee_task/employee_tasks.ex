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
  This function is also called when barcode scan success, so it is not weight-based product
  """
  def update_employee_task_line_item_status(employee_id, line_item_id, status) do
    employee_task = Repo.get_by(EmployeeTask, employee_id: employee_id)
    existing_line_items = employee_task.line_items

    # exclude selected line item from existing line_items then convert to map
    existing_line_items_map =
      existing_line_items
      |> Enum.filter(fn line_item -> line_item.id != line_item_id end)
      |> Enum.map(&Map.from_struct/1)

    # Get selected line_item
    [line_item] = Enum.filter(existing_line_items, &(&1.id == line_item_id))

    line_item_map =
      if(status == "not_ready") do
        # Reset final_quantity to nil and weight to nil
        # and Convert to map and update status value
        line_item
        |> Map.from_struct()
        |> Map.put(:status, status)
        |> Map.put(:final_quantity, nil)
        |> Map.put(:weight, nil)
      else
        # ready case, it's called from barcode scan so it is not weight based
        # copy quantity into final_quantity.
        # more than 1 quantity will call update_quantity_or_weight_for_line_item function
        line_item
        |> Map.from_struct()
        |> Map.put(:status, status)
        |> Map.put(:final_quantity, line_item.quantity)
      end

    employee_task_attrs = %{line_items: [line_item_map | existing_line_items_map]}
    update_employee_task(employee_task, employee_task_attrs)
  end

  def update_quantity_or_weight_for_line_item(:quantity, employee_id, line_item_id, quantity) do
    IO.puts("Calling check_quantity_for_line_item function")
    employee_task = Repo.get_by(EmployeeTask, employee_id: employee_id)
    existing_line_items = employee_task.line_items

    # exclude selected line item from existing line_items then convert to map
    existing_line_items_map =
      existing_line_items
      |> Enum.filter(fn line_item -> line_item.id != line_item_id end)
      |> Enum.map(&Map.from_struct/1)

    # Get selected line_item
    [line_item] = Enum.filter(existing_line_items, &(&1.id == line_item_id))

    case Integer.parse(quantity) do
      {quantity_int, _rest} ->
        if(quantity_int > 0 && quantity_int <= line_item.quantity) do
          # update line_item along with employee task
          # Convert to map and update value
          line_item_map =
            line_item
            |> Map.from_struct()
            |> Map.put(:final_quantity, quantity_int)
            |> Map.put(:status, :ready)

          employee_task_attrs = %{line_items: [line_item_map | existing_line_items_map]}
          update_employee_task(employee_task, employee_task_attrs)
        else
          {:error, "상품의 수량을 확인하세요"}
        end

      :error ->
        {:error, "상품의 수량을 확인하세요"}
    end
  end

  def update_quantity_or_weight_for_line_item(:weight, employee_id, line_item_id, weight) do
    IO.puts("Calling check_quantity_for_line_item function")
    employee_task = Repo.get_by(EmployeeTask, employee_id: employee_id)
    existing_line_items = employee_task.line_items

    # exclude selected line item from existing line_items then convert to map
    existing_line_items_map =
      existing_line_items
      |> Enum.filter(fn line_item -> line_item.id != line_item_id end)
      |> Enum.map(&Map.from_struct/1)

    # Get selected line_item
    [line_item] = Enum.filter(existing_line_items, &(&1.id == line_item_id))

    case Float.parse(weight) do
      {weight_float, _rest} ->
        weight_limit = line_item.quantity + 1.0

        if(weight_float > 0 && weight_float <= weight_limit) do
          # update line_item along with employee task
          # Convert to map and update value
          line_item_map =
            line_item
            |> Map.from_struct()
            |> Map.put(:weight, weight_float)
            |> Map.put(:status, :ready)

          employee_task_attrs = %{line_items: [line_item_map | existing_line_items_map]}
          update_employee_task(employee_task, employee_task_attrs)
        else
          {:error, "상품의 무게를 확인하세요"}
        end

      :error ->
        {:error, "상품의 무게를 확인하세요"}
    end

    # Even though line item is weight based,
    # quantity means weight for this product.
  end
end
