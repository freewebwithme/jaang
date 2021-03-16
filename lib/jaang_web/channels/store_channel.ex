defmodule JaangWeb.StoreChannel do
  use Phoenix.Channel
  alias Jaang.Admin.Invoice.Invoices
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Admin.EmployeeTask.EmployeeTasks

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
      {:ok, grouped_invoices} ->
        {:reply,
         {:ok,
          %{
            submitted: grouped_invoices.submitted,
            shopping: grouped_invoices.shopping,
            packed: grouped_invoices.packed,
            on_the_way: grouped_invoices.on_the_way
          }}, socket}

      {:empty, %{}} ->
        {:reply, {:ok, %{has_data: false}}, socket}
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

    # employee = EmployeeAccountManager.get_employee(employee_id)

    IO.puts("Printing employee task")
    IO.inspect(employee_task)
    # Send reply with updated invoice
    {:reply, {:ok, %{employee_task: employee_task}}, socket}
  end

  @impl true
  @doc """
  Whenever invoice is updated, send updated invoice and updated invoice list
  using handle_in
  """
  def handle_out("invoice_updated", _message, %{assigns: %{store_id: store_id}} = socket) do
    IO.puts("invoice updated handle out: ")

    case return_grouped_invoices(store_id) do
      {:ok, grouped_invoices} ->
        push(socket, "invoice_updated", %{
          # invoice: invoice,
          submitted: grouped_invoices.submitted,
          shopping: grouped_invoices.shopping,
          packed: grouped_invoices.packed,
          on_the_way: grouped_invoices.on_the_way
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
      {:ok, grouped_invoices}
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
end
