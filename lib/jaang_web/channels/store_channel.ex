defmodule JaangWeb.StoreChannel do
  use Phoenix.Channel
  alias Jaang.Admin.Invoice.Invoices

  intercept ["new_order"]

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

    {submitted, shopping, packed, on_the_way} = return_grouped_invoices(store_id)

    {:reply,
     {:ok,
      %{
        submitted: submitted,
        shopping: shopping,
        packed: packed,
        on_the_way: on_the_way
      }}, socket}
  end

  @impl true
  def handle_in("start_shopping", payload, socket) do
    # Get employee id and invoice id from payload
    # Get employee and invoice
    # Set invoice :employees to employee
    # update invoice and order status to :shopping
    # return new grouped_invoices
  end

  @impl true
  def handle_info({:send_order_info, event}, %{assigns: %{store_id: store_id}} = socket) do
    IO.puts("Printing store_id #{store_id}")
    {submitted, shopping, packed, on_the_way} = return_grouped_invoices(store_id)

    push(socket, event, %{
      submitted: submitted,
      shopping: shopping,
      packed: packed,
      on_the_way: on_the_way
    })

    {:noreply, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp return_grouped_invoices(store_id) do
    grouped_invoices = Invoices.get_unfulfilled_invoices(store_id)

    {
      grouped_invoices.submitted,
      grouped_invoices.shopping,
      grouped_invoices.packed,
      grouped_invoices.on_the_way
    }
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
