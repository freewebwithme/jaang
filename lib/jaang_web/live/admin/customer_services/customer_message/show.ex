defmodule JaangWeb.Admin.CustomerServices.CustomerMessageLive.Show do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.CustomerServices

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: CustomerServices.subscribe()

    customer_message = CustomerServices.get_customer_message(id)

    statuses = [
      %{
        status: "New_request",
        desc: "Just received this message, Admin is currently not working on this"
      },
      %{status: "In_progress", desc: "Admin is working on this issue"},
      %{status: "Completed", desc: "Admin completed this issue"}
    ]

    {:ok,
     assign(socket,
       customer_message: customer_message,
       current_page: "Customer message detail",
       statuses: statuses,
       current_status: Helpers.convert_atom_and_string(customer_message.status)
     )}
  end

  def handle_event(
        "change-state",
        %{"customer-message-status" => state, "customer-message-id" => _customer_message_id},
        socket
      ) do
    # Change string to atom
    new_state = Helpers.convert_atom_and_string(state)
    IO.inspect(new_state)

    {:ok, customer_message} =
      CustomerServices.update_customer_message(socket.assigns.customer_message, %{
        status: new_state
      })

    {:noreply,
     assign(socket,
       customer_message: customer_message,
       current_status: Helpers.convert_atom_and_string(customer_message.status)
     )}
  end
end
