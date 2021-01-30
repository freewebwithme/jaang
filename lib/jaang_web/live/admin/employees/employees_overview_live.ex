defmodule JaangWeb.Admin.Employees.EmployeesOverviewLive do
  use JaangWeb, :dashboard_live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Employees Overview")
    {:ok, socket}
  end
end
