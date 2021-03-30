defmodule JaangWeb.StoreChannel do
  use Phoenix.Channel
  alias Jaang.Admin.Invoice.Invoices
  alias Jaang.Admin.EmployeeTask.EmployeeTasks
  alias Jaang.Admin.EmployeeTask

  intercept ["invoice_updated"]

  @impl true
  def join("store:" <> store_id, _params, %{assigns: %{current_employee: employee}} = socket) do
    # Check if current employee is employee of current store
    if employee_belongs_to_store?(employee, store_id) do
      IO.puts("Joining store channel: #{store_id}")
      socket = assign(socket, store_id: store_id)
      # grouped_invoices = Invoices.get_unfulfilled_invoices(store_id)

      # {:ok,
      # %{
      #   submitted: grouped_invoices.submitted,
      #   packed: grouped_invoices.packed,
      #   on_the_way: grouped_invoices.on_the_way
      # }, socket}
      {:ok, socket}
    else
      {:error, %{reason: "unauthenticated"}}
    end
  end

  def join("store:" <> _store_id, _params, _socket) do
    IO.puts("Can't join a chnannel")
    {:error, %{reason: "unauthenticated"}}
  end

  @impl true
  def handle_in("get_order_info", _payload, %{assigns: %{store_id: store_id}} = socket) do
    IO.puts("Incoming event from client: 'get_order_info'")

    case return_grouped_invoices(store_id) do
      {:ok, %{submitted: submitted, shopping: shopping, packed: packed, on_the_way: on_the_way}} ->
        {:reply,
         {:ok,
          %{
            submitted: submitted,
            shopping: shopping,
            packed: packed,
            on_the_way: on_the_way
          }}, socket}

      {:empty, %{}} ->
        {:reply, {:ok, %{has_data: false}}, socket}
    end
  end

  # This handle_in function to check if employee has in-progress task that must finish
  @impl true
  def handle_in("check_employee_task", %{"employee_id" => employee_id} = _payload, socket) do
    IO.puts("Incoming event from client: 'check_employee_task'")
    IO.inspect(employee_id)

    case EmployeeTasks.get_in_progress_employee_task(employee_id) do
      nil ->
        {:reply, {:ok, %{has_in_progress_task: false}}, socket}

      employee_task ->
        # get invoice and return with employee_task
        invoice = Invoices.get_invoice(employee_task.invoice_id)

        # Group by line items' status
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        {:reply,
         {:ok,
          %{
            has_in_progress_task: true,
            employee_task: employee_task,
            invoice: invoice,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}
    end
  end

  @impl true
  def handle_in("start_shopping", payload, socket) do
    IO.puts("Calling handle_in('start_shopping')")
    %{"invoice_id" => invoice_id, "employee_id" => employee_id} = payload
    # IO.puts("invoice_id #{invoice_id}, employee_id: #{employee_id}")

    {:ok, invoice} = Invoices.assign_employee_to_invoice(invoice_id, employee_id, :shopping)

    # Create employee task
    {:ok, employee_task} =
      EmployeeTasks.create_employee_task(invoice, employee_id, "shopping", "in_progress")

    # Group by line items' status
    %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
      group_by_line_item_status(employee_task)

    IO.puts("Printing employee task")
    IO.inspect(employee_task)
    # Send reply with updated invoice
    {:reply,
     {:ok,
      %{
        employee_task: employee_task,
        invoice: invoice,
        ready: ready,
        not_ready: not_ready,
        sold_out: sold_out
      }}, socket}
  end

  @impl true
  def handle_in(
        "continue_shopping",
        %{"invoice_id" => invoice_id, "employee_id" => employee_id} = _payload,
        socket
      ) do
    IO.puts("Calling handle_in(`continue_shopping')")
    employee_task = EmployeeTasks.get_employee_task(employee_id)
    # Group by line items' status
    %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
      group_by_line_item_status(employee_task)

    invoice = Invoices.get_invoice(invoice_id)
    IO.inspect(ready)
    # Send reply with updated invoice
    {:reply,
     {:ok,
      %{
        employee_task: employee_task,
        invoice: invoice,
        ready: ready,
        not_ready: not_ready,
        sold_out: sold_out
      }}, socket}
  end

  @impl true
  def handle_in(
        "update_line_item",
        %{"employee_id" => employee_id, "line_item_id" => line_item_id, "status" => status},
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item`")

    case EmployeeTasks.update_employee_task_line_item_status(employee_id, line_item_id, status) do
      {:ok, _employee_task} ->
        {:reply, :ok, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in(
        "update_line_item_quantity_or_weight",
        %{"employee_id" => employee_id, "line_item_id" => line_item_id, "quantity" => quantity},
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item_quantity_or_weight`)")
  end

  @impl true
  @doc """
  Whenever invoice is updated, send updated invoice and updated invoice list
  using handle_in
  """
  def handle_out("invoice_updated", _message, %{assigns: %{store_id: store_id}} = socket) do
    IO.puts("invoice updated handle out: ")

    case return_grouped_invoices(store_id) do
      {:ok, %{submitted: submitted, shopping: shopping, packed: packed, on_the_way: on_the_way}} ->
        push(socket, "invoice_updated", %{
          # invoice: invoice,
          submitted: submitted,
          shopping: shopping,
          packed: packed,
          on_the_way: on_the_way
        })

        {:noreply, socket}

      {:empty, %{}} ->
        push(socket, "invoice_updated", %{has_data: false})
        {:noreply, socket}
    end
  end

  # @impl true
  # def handle_info({:send_order_info, event}, %{assigns: %{store_id: store_id}} = socket) do
  #   IO.puts("Printing store_id #{store_id}")
  #   {submitted, shopping, packed, on_the_way} = return_grouped_invoices(store_id)

  #   push(socket, event, %{
  #     submitted: submitted,
  #     shopping: shopping,
  #     packed: packed,
  #     on_the_way: on_the_way
  #   })

  #   {:noreply, socket}
  # end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp return_grouped_invoices(store_id) do
    grouped_invoices = Invoices.get_unfulfilled_invoices(store_id)

    if grouped_invoices == %{} do
      {:empty, %{}}
    else
      {:ok,
       %{
         submitted: Map.get(grouped_invoices, :submitted) || [],
         shopping: Map.get(grouped_invoices, :shopping) || [],
         packed: Map.get(grouped_invoices, :packed) || [],
         on_the_way: Map.get(grouped_invoices, :on_the_way) || []
       }}
    end
  end

  defp employee_belongs_to_store?(employee, store_id) do
    store_id = String.to_integer(store_id)

    stores =
      Enum.filter(employee.assigned_stores, fn store ->
        store.id == store_id
      end)

    result =
      case Enum.count(stores) > 0 do
        true -> true
        _ -> false
      end

    result
  end

  defp group_by_line_item_status(%EmployeeTask{} = employee_task) do
    {ready, not_ready, sold_out} =
      Enum.group_by(employee_task.line_items, & &1.status)
      |> group_by_category_name()

    %{
      ready: ready,
      not_ready: not_ready,
      sold_out: sold_out
    }
  end

  defp group_by_category_name(grouped_line_items) do
    ready_line_items = Map.get(grouped_line_items, :ready)
    not_ready_line_items = Map.get(grouped_line_items, :not_ready)
    sold_out_line_items = Map.get(grouped_line_items, :sold_out)

    ready_line_items =
      if ready_line_items do
        Enum.group_by(ready_line_items, & &1.category_name)
      else
        %{}
      end

    not_ready_line_items =
      if not_ready_line_items do
        Enum.group_by(not_ready_line_items, & &1.category_name)
      else
        %{}
      end

    sold_out_line_items =
      if sold_out_line_items do
        Enum.group_by(sold_out_line_items, & &1.category_name)
      else
        %{}
      end

    {ready_line_items, not_ready_line_items, sold_out_line_items}
  end
end
