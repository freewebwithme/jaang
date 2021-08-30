defmodule JaangWeb.Admin.Components.RoleFormComponent do
  use JaangWeb, :live_component
  alias Jaang.Admin.EmployeeAccountManager

  def update(%{role: role} = assigns, socket) do
    changeset = EmployeeAccountManager.change_employee_role(role, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="flex items-center justify-between">
        <h2 class="py-2 px-10 text-xl text-gray-900">
        <%= @title %>
        </h2>
      </div>

      <div class="max-w-2xl">
        <.form let={f} for={@changeset} url="#" phx-submit="save" phx-change="validate" phx-target={@myself} class="space-y-6 sm:space-y-5">
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :name, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= text_input f, :name,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :name %>
            </div>
            <div class="flex ">
              <%= submit "Save", [
                class: (if @can_save, do: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
                else: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-gray-500 bg-gray-300 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"),
                phx_disable_with: "Saving..."
                ]
              %>
              <%= live_redirect to: @return_to,
                  class: "ml-4 relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
              do %>
                Cancel
              <% end %>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("validate", %{"employee_role" => attrs}, socket) do
    changeset =
      EmployeeAccountManager.change_employee_role(socket.assigns.role, attrs)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset, can_save: changeset.valid?)
    {:noreply, socket}
  end

  def handle_event("save", %{"employee_role" => attrs}, socket) do
    save_role(socket, socket.assigns.action, attrs)
  end

  defp save_role(socket, :edit, attrs) do
    case EmployeeAccountManager.update_employee_role(socket.assigns.role, attrs) do
      {:ok, _employee} ->
        IO.puts("role updated")
        IO.inspect(socket.assigns.return_to)

        socket =
          socket
          |> put_flash(:info, "Role updated successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:noreply, socket}

      {:error, changeset} ->
        IO.puts("role update fail")
        {:noreply, assign(socket, changeset: changeset, can_save: changeset.valid?)}
    end
  end

  defp save_role(socket, :add, attrs) do
    case EmployeeAccountManager.create_employee_role(attrs) do
      {:ok, _employee} ->
        IO.puts("role created")

        IO.inspect(socket.assigns.return_to)

        socket =
          socket
          |> put_flash(:info, "New role added successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:noreply, socket}

      {:error, changeset} ->
        IO.puts("role create fail")
        {:noreply, assign(socket, changeset: changeset, can_save: changeset.valid?)}
    end
  end
end
