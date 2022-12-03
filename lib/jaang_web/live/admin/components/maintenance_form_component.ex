defmodule JaangWeb.Admin.Components.MaintenanceFormComponent do
  use JaangWeb, :live_component
  alias Jaang.Store.Maintenance

  @moduledoc false

  def update(%{maintenance: maintenance} = assigns, socket) do
    changeset = Maintenance.change_maintenance(maintenance, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="border-b pb-3 border-gray-200">
        <h3 class="text-lg leading-6 font-medium text-gray-900"><%= @title %></h3>
        <p class="mt-1 max-w-2xl text-sm text-gray-500">If you start a maintenance mode, mobile app will be also in maintenance mode. </p>
      </div>

      <div class="max-w-2xl">
        <.form let={f} for={@changeset} phx-submit="create" phx-change="validate" phx-target={@myself} class="space-y-6 sm:space-y-5">

          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <%= label f, :message, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
            <div class="mt-1 sm:mt-0 sm:col-span-2">
              <%= textarea f, :message,
              [phx_debounce: "500",
               required: true,
               class: "max-w-lg block w-full shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
              <%= error_tag f, :message %>
            </div>
          </div>
          <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <p class="block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2">Maintenance mode</p>

            <div class="grid grid-cols-2 items-center">
                <%= label f, "On", class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
                <%= radio_button f, :in_maintenance_mode, "true", class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 sm:mt-px sm:pt-2" %>
            </div>

            <div class="grid grid-cols-2 items-center">
                <%= label f, "Off", class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
                <%= radio_button f, :in_maintenance_mode, "false", class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300" %>
            </div>
          </div>


          <%= if @live_action == :edit do %>
            <div class="sm:grid sm:grid-cols-5 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
              <%= label f, :archived, class: "block text-center text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" %>
              <div class="mt-1 sm:mt-0 sm:col-span-2">
                <%= checkbox f, :archived,
                  [phx_debounce: "500",
                  class: "max-w-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md"] %>
                <%= error_tag f, :archived %>
                <p class="font-light text-sm mt-2">If archived is checked, maintenance mode is off (finished) and you can't edit this anymore.</p>
              </div>
            </div>
          <% end %>
          <div class="sm:grid sm:grid-cols-2 sm:gap-4 sm:items-start sm:pt-5 sm:pb-5">
            <div class="flex">
              <%= if @live_action == :add do %>
                <%= submit "Create", [
                  class: (if @can_save, do: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3",
                  else: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-gray-500 bg-gray-300 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"),
                  phx_disable_with: "Creating..."
                  ]
                %>
              <% else %>
                <%= submit "Edit", [
                  class: (if @can_save, do: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3",
                  else: "relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-gray-500 bg-gray-300 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"),
                  phx_disable_with: "Editing...",
                  ]
                %>

              <% end %>
                <.link navigate={@return_to}
                  class="ml-4 relative inline-flex items-center px-6 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  Cancel
                </.link>
            </div>
          </div>
        </.form>
      </div>
    </div>

    """
  end

  def handle_event(
        "validate",
        %{"maintenance" => maintenance_params},
        %{assigns: %{maintenance: maintenance}} = socket
      ) do
    changeset =
      maintenance
      |> Maintenance.change_maintenance(maintenance_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:can_save, changeset.valid?)}
  end

  @doc """
  Create(start) maintenance mode
  """
  def handle_event(
        "create",
        %{"maintenance" => maintenance_params},
        %{assigns: %{maintenance: _maintenance, live_action: :add}} = socket
      ) do
    now = Timex.now()
    params_with_start_datetime = Map.put(maintenance_params, "start_datetime", now)

    case Maintenance.create_maintenance(params_with_start_datetime) do
      {:ok, maintenance} ->
        send(self(), {:new_maintenance, maintenance})

        socket =
          socket
          |> put_flash(:info, "New Maintenance created")
          |> push_navigate(to: socket.assigns.return_to, replace: true)

        {:noreply, socket}

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Error creating maintenance")
        |> assign(:changeset, changeset)

        {:noreply, socket}
    end
  end

  # Edit maintenance mode
  def handle_event(
        "create",
        %{"maintenance" => maintenance_params},
        %{assigns: %{maintenance: maintenance, live_action: :edit}} = socket
      ) do
    case Maintenance.update_maintenance(maintenance, maintenance_params) do
      {:ok, maintenance} ->
        send(self(), {:maintenance_updated, maintenance})

        socket =
          socket
          |> put_flash(:info, "Maintenance updated successfully")
          |> push_navigate(to: socket.assigns.return_to, replace: true)

        {:noreply, socket}

      {:error, %Ecto.Changeset{errors: [archived: _error]} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Can't edit archived maintenance")
          |> assign(:changeset, changeset)
          |> push_navigate(to: socket.assigns.return_to, replace: true)

        {:noreply, socket}

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Error updating maintenance")
        |> assign(:changeset, changeset)

        {:noreply, socket}
    end
  end
end
