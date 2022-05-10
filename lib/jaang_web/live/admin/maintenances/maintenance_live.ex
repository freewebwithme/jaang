defmodule JaangWeb.Admin.Maintenances.MaintenanceLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Store.Maintenance

  @moduledoc false

  def mount(_params, _session, socket) do
    maintenances = Maintenance.list_maintenances()

    {:ok,
     assign(socket,
       maintenances: maintenances,
       current_page: "Maintenances",
       temporary_assigns: []
     )}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_info({:new_maintenance, maintenance}, socket) do
    IO.inspect(maintenance)
    {:noreply, socket}
  end

  defp apply_action(socket, :add, _params) do
    socket
    |> assign(:page_title, "Create a maintenance")
    |> assign(:maintenance, %Maintenance{})
  end

  defp apply_action(socket, :index, _params) do
    socket
  end
end
