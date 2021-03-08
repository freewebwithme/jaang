defmodule JaangWeb.StoreChannel do
  use Phoenix.Channel

  intercept ["new_order"]

  @impl true
  def join("store:" <> store_id, _params, %{assigns: %{current_employee: employee}} = socket) do
    # Check if current employee is employee of current store
    if employee_belongs_to_store?(employee, store_id) do
      IO.puts("Joining store channel: #{store_id}")
      {:ok, %{message: "Welcome"}, socket}
    else
      {:error, %{reason: "unauthenticated"}}
    end
  end

  def join("store:" <> _store_id, _params, _socket) do
    IO.puts("Can't join a chnannel")
    {:error, %{reason: "unauthenticated"}}
  end

  @impl true
  def handle_in("new_order", payload, socket) do
    IO.inspect(payload)
    IO.puts("Incoming new order")
    {:reply, {:ok, %{message: "New order"}}, socket}
  end

  @impl true
  def handle_out("new_order", message, socket) do
    IO.puts("New order message sending out")
    IO.inspect(message)
    user = Jaang.AccountManager.get_user(7)
    push(socket, "new_order", message)
    {:noreply, socket}
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
