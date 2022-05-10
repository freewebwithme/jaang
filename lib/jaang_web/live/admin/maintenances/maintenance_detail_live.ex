defmodule JaangWeb.Admin.Maintenances.MaintenanceDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Store.Maintenance
  alias JaangWeb.Admin.Helpers

  @moduledoc false

  def mount(%{"id" => maintenance_id}, _session, socket) do
    maintenance = Maintenance.get_maintenance(maintenance_id)

    {:ok,
     socket
     |> assign(:maintenance, maintenance)
     |> assign(:current_page, "Maintenance detail")}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Maintenance detail")
  end

  defp apply_action(socket, :edit, %{"id" => maintenance_id}) do
    socket
    |> assign(:page_title, "Edit a maintenance")
    |> assign(:maintenance_id, maintenance_id)
  end
end
