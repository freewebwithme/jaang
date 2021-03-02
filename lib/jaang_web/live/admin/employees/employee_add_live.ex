defmodule JaangWeb.Admin.Employees.EmployeeAddLive do
  use JaangWeb, :dashboard_live_view
  alias JaangWeb.Admin.Employees.EmployeeAddLive

  def mount(_params, _session, socket) do
    socket = assign(socket, current_page: "Employee Add")
    {:ok, socket}
  end
end
