defmodule Jaang.Admin.EmployeeTask.EmployeeTasks do
  alias Jaang.Repo
  alias Jaang.Admin.EmployeeTask
  alias Jaang.Invoice
  alias Jaang.Admin.Order.Orders
  import Ecto.Query

  def create_employee_task(%{} = attrs) do
    %EmployeeTask{}
    |> EmployeeTask.changeset(attrs)
    |> Repo.insert()
  end

  def create_employee_task(order_id, employee_id, task_type, task_status) do
    order = Orders.get_order(order_id)

    # if there is a replacement item, convert it to map
    line_items_maps =
      Enum.map(order.line_items, fn line_item ->
        if(line_item.has_replacement) do
          updated_line_item =
            Map.update!(line_item, :replacement_item, fn value -> Map.from_struct(value) end)

          Map.from_struct(updated_line_item)
        else
          Map.from_struct(line_item)
        end
      end)

    attrs = %{
      task_type: task_type,
      task_status: task_status,
      start_datetime: Timex.now(),
      invoice_id: order.invoice_id,
      order_id: order.id,
      employee_id: employee_id,
      line_items: line_items_maps
    }

    create_employee_task(attrs)
  end

  def get_employee_task(employee_id) do
    Repo.get_by(EmployeeTask, employee_id: employee_id)
  end

  def get_employee_task_by_id(employee_task_id) do
    Repo.get_by(EmployeeTask, id: employee_task_id)
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
  def update_employee_task_line_item_status(
        employee_id,
        line_item_id,
        status,
        refund_reason \\ nil
      ) do
    employee_task = get_in_progress_employee_task(employee_id)

    {rest_line_items, line_item} =
      convert_line_items_to_map_and_return(employee_task.line_items, line_item_id)

    updated_line_item =
      cond do
        # Reset final_quantity to nil and weight to nil
        status == "not_ready" ->
          line_item
          |> Map.put(:status, status)
          |> Map.put(:final_quantity, nil)
          |> Map.put(:weight, nil)

        status == "sold_out" ->
          line_item
          |> Map.put(:status, status)
          |> Map.put(:refund_reason, refund_reason)
          |> Map.put(:final_quantity, 0)
          |> Map.put(:weight, 0.0)

        status == "ready" ->
          # ready case, it's called from barcode scan so it is not weight based
          # copy quantity into final_quantity.
          # more than 1 quantity will call update_quantity_or_weight_for_line_item function
          line_item
          |> Map.put(:status, status)
          |> Map.put(:final_quantity, line_item.quantity)
      end

    employee_task_attrs = %{line_items: [updated_line_item | rest_line_items]}
    update_employee_task(employee_task, employee_task_attrs)
  end

  @doc """
  This function is used when barcode product is out of stock so shopper choose
  replacement item.(status == ready) or remove it from cart(status == not_ready)
  """
  def update_employee_task_replacement_for_barcode_product(
        employee_id,
        line_item_id,
        replacement_item_id,
        status
      ) do
    employee_task = get_in_progress_employee_task(employee_id)

    {rest_line_items, line_item} =
      convert_line_items_to_map_and_return(employee_task.line_items, line_item_id)

    if(line_item.replacement_item.id == replacement_item_id) do
      updated_line_item =
        cond do
          status == "ready" ->
            # This means that shopper found a replacement item for the barcode product
            # Now update both original line_item and replacement line_item
            line_item
            |> Map.update!(:status, fn _value -> status end)
            |> Map.update!(:replaced, fn _value -> true end)
            |> Map.update!(:final_quantity, fn _value -> 0 end)
            |> Map.update!(:replacement_item, fn replacement_item ->
              replacement_item
              |> Map.update!(:status, fn _value -> status end)
              |> Map.update!(:final_quantity, fn _value -> line_item.quantity end)
            end)

          status == "not_ready" ->
            # This means that shopper changes status ready from not_ready(removing item)
            line_item
            |> Map.update!(:status, fn _value -> status end)
            |> Map.update!(:replaced, fn _value -> false end)
            |> Map.update!(:final_quantity, fn _value -> nil end)
            |> Map.update!(:replacement_item, fn replacement_item ->
              replacement_item
              |> Map.update!(:status, fn _value -> status end)
              |> Map.update!(:final_quantity, fn _value -> nil end)
            end)
        end

      employee_task_attrs = %{line_items: [updated_line_item | rest_line_items]}
      update_employee_task(employee_task, employee_task_attrs)
    else
      {:error, "대체 상품으로 지정할 수 없습니다"}
    end
  end

  def update_quantity_or_weight_for_line_item(:quantity, employee_id, line_item_id, quantity) do
    IO.puts("Calling check_quantity_for_line_item function")
    employee_task = get_in_progress_employee_task(employee_id)

    {rest_line_items, line_item} =
      convert_line_items_to_map_and_return(employee_task.line_items, line_item_id)

    case Integer.parse(quantity) do
      {quantity_int, _rest} ->
        if(quantity_int > 0 && quantity_int <= line_item.quantity) do
          # update line_item along with employee task
          # Convert to map and update value
          updated_line_item =
            line_item
            |> Map.put(:final_quantity, quantity_int)
            |> Map.put(:status, :ready)

          employee_task_attrs = %{line_items: [updated_line_item | rest_line_items]}
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
    employee_task = get_in_progress_employee_task(employee_id)

    {rest_line_items_map, line_item} =
      convert_line_items_to_map_and_return(employee_task.line_items, line_item_id)

    case Float.parse(weight) do
      {weight_float, _rest} ->
        weight_limit = line_item.quantity + 0.2

        if(weight_float > 0 && weight_float <= weight_limit) do
          # update line_item along with employee task
          # Convert to map and update value
          updated_line_item =
            line_item
            |> Map.put(:weight, weight_float)
            |> Map.put(:status, :ready)

          employee_task_attrs = %{line_items: [updated_line_item | rest_line_items_map]}
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

  def update_line_item_with_replacement_for_no_barcode(
        :quantity,
        employee_id,
        line_item_id,
        replacement_line_item_id,
        quantity
      ) do
    IO.puts("Calling update_line_item_with_replacement")
    employee_task = get_in_progress_employee_task(employee_id)

    {rest_line_items, line_item} =
      convert_line_items_to_map_and_return(employee_task.line_items, line_item_id)

    with true <- line_item.replacement_item.id == replacement_line_item_id,
         {quantity_int, _rest} <- Integer.parse(quantity) do
      # replacement item is matched, go ahead process

      updated_line_item =
        line_item
        |> Map.update!(:replacement_item, fn replacement_item ->
          Map.update!(replacement_item, :final_quantity, fn _value -> quantity_int end)
          |> Map.update!(:status, fn _value -> :ready end)
        end)
        |> Map.update!(:replaced, fn _value -> true end)
        |> Map.update!(:status, fn _value -> :ready end)
        |> Map.update!(:final_quantity, fn _value -> 0 end)
        |> Map.update!(:weight, fn _value -> 0.0 end)

      employee_task_attrs = %{line_items: [updated_line_item | rest_line_items]}
      update_employee_task(employee_task, employee_task_attrs)
    else
      :error ->
        {:error, "대체 상품으로 지정할 수 없습니다"}

      false ->
        {:error, "대체 상품으로 지정할 수 없습니다"}
    end
  end

  def update_line_item_with_replacement_for_no_barcode(
        :weight,
        employee_id,
        line_item_id,
        replacement_line_item_id,
        weight
      ) do
    IO.puts("Calling update_line_item_with_replacement")
    employee_task = get_in_progress_employee_task(employee_id)

    {rest_line_items, line_item} =
      convert_line_items_to_map_and_return(employee_task.line_items, line_item_id)

    with true <- line_item.replacement_item.id == replacement_line_item_id,
         {weight_float, _rest} <- Float.parse(weight) do
      # replacement item is matched, go ahead process

      updated_line_item =
        line_item
        |> Map.update!(:replacement_item, fn replacement_item ->
          Map.update!(replacement_item, :weight, fn _value -> weight_float end)
          |> Map.update!(:status, fn _value -> :ready end)
        end)
        |> Map.update!(:replaced, fn _value -> true end)
        |> Map.update!(:status, fn _value -> :ready end)
        |> Map.update!(:weight, fn _value -> 0.0 end)
        |> Map.update!(:final_quantity, fn _value -> 0 end)

      employee_task_attrs = %{line_items: [updated_line_item | rest_line_items]}
      update_employee_task(employee_task, employee_task_attrs)
    else
      :error ->
        {:error, "대체 상품으로 지정할 수 없습니다"}

      false ->
        {:error, "대체 상품으로 지정할 수 없습니다"}
    end
  end

  defp convert_line_items_to_map_and_return(line_items, selected_line_item_id) do
    existing_line_items_map =
      line_items
      |> Enum.map(fn line_item ->
        # check if line_item has replacement item
        if(line_item.has_replacement) do
          Map.update!(line_item, :replacement_item, fn value ->
            Map.from_struct(value)
          end)
          |> Map.from_struct()
        else
          Map.from_struct(line_item)
        end
      end)

    # exclude selected line item from existing line_items then convert to map
    rest_line_items_map =
      existing_line_items_map
      |> Enum.filter(fn line_item -> line_item.id != selected_line_item_id end)

    # Get selected line_item
    [line_item] = Enum.filter(existing_line_items_map, &(&1.id == selected_line_item_id))

    {rest_line_items_map, line_item}
  end
end
