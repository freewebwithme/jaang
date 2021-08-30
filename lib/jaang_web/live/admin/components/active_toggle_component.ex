defmodule JaangWeb.Admin.Components.ActiveToggleComponent do
  use JaangWeb, :live_component
  alias Jaang.Admin.EmployeeAccountManager

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div x-data="{on: {@changeset.data.active}}" class="flex items-center">
      <!-- Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200" -->
      <button x-state:on="Enabled" x-state:off="Not Enabled"
              :class="{'bg-indigo-600': on, 'bg-gray-200': !(on)}"
              @click="on = !on"
              type="button" class="bg-gray-200 relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" aria-pressed="false" aria-labelledby="product-published-label"
              phx-click="activate"
              phx-target="{@myself}"
              phx-value-active={!@changeset.data.active}
              >
        <span class="sr-only">employee active</span>
        <!-- Enabled: "translate-x-5", Not Enabled: "translate-x-0" -->
        <span aria-hidden="true"
              :class="{'translate-x-5': on, 'translate-x-0': !(on)}"
              x-state:on="Enabled" x-state:off="Not Enabled"
              class="translate-x-0 pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"></span>
      </button>
      <span class="ml-3" id="annual-billing-label">
        <span class="mr-5 text-sm font-medium text-gray-900">Active?</span>
      </span>
    </div>
    """
  end

  def handle_event("activate", %{"active" => active}, socket) do
    IO.inspect(socket.assigns.changeset.data)
    IO.inspect(active)
    changeset = EmployeeAccountManager.change_employee(socket.assigns.employee, %{active: active})

    case EmployeeAccountManager.update_employee(changeset) do
      {:ok, updated_employee} ->
        send(self(), {:updated_employee, updated_employee})

        {:noreply, socket}

      {:error, changeset} ->
        send(self(), {:update_employee_error, changeset})
        {:noreply, socket}
    end

    # If the update succeeds, you must not change the product assigns inside the component.
    # If you do so, the product assigns in the component will get out of sync with the LiveView.
    # Since the LiveView is the source of truth, you should instead tell the LiveView that i
    # the product was updated.
  end
end
