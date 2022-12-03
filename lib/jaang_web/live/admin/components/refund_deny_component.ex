defmodule JaangWeb.Admin.Components.RefundDenyComponent do
  use JaangWeb, :live_component
  use Phoenix.HTML
  alias Jaang.Admin.CustomerServices

  def update(%{refund_request: refund_request} = assigns, socket) do
    changeset = CustomerServices.change_refund_request(refund_request, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def render(assigns) do
    ~H"""
     <div class="container mx-auto">
        <p class="text-lg font-medium pb-10"> Do you want to deny this request? </p>

        <.form let={f} for={@changeset} phx-change="validate" phx-submit="deny" phx-target={@myself}>
          <div class="pb-5">
            <label>Type deny reason</label>
          </div>
          <div class="pb-5">
            <%= textarea f, :deny_reason, phx_debounce: 500 %>
          </div>
          <%= if @changeset.valid? == false do %>
          <div class="pb-5">
            <p class="text-sm font-bold text-red-700"> Please enter why you are denying this request</p>
          </div>
          <% end %>

          <div class="flex">
            <div class="pr-2">
              <button type="button"
                phx-click="close"
                phx-target={@myself}
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
                Cancel
              </button>
            </div>
            <div class="">
              <%= if @changeset.valid? do %>
              <%= submit "Deny",
                 class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              %>

              <% else %>

              <%= submit "Deny",
                 class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-gray-900 bg-gray-100 hover:bg-gray-600 hover:text-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500",
                 disabled: "disabled"
              %>
              <% end %>

            </div>
          </div>
        </.form>
     </div>
    """
  end

  def handle_event(
        "validate",
        %{"refund_request" => %{"deny_reason" => deny_reason}} = _params,
        %{assigns: %{refund_request: refund_request}} = socket
      ) do
    changeset =
      refund_request
      |> CustomerServices.change_refund_request(%{deny_reason: deny_reason})
      |> Ecto.Changeset.validate_length(:deny_reason, min: 5)
      |> Map.put(:action, :validate)

    socket =
      assign(socket, :changeset, changeset)
      |> assign(:can_save, changeset.valid?)

    {:noreply, socket}
  end

  def handle_event(
        "deny",
        %{"refund_request" => %{"deny_reason" => deny_reason}},
        %{assigns: %{refund_request: refund_request}} = socket
      ) do
    case CustomerServices.update_refund_request(refund_request, %{
           deny_reason: deny_reason,
           status: :denied
         }) do
      {:ok, updated_refund_request} ->
        send(self(), {:updated, updated_refund_request})

        socket =
          socket
          |> put_flash(:info, "Refund request denied successfully")
          |> push_navigate(to: socket.assigns.return_to)

        {:noreply, socket}
    end
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
