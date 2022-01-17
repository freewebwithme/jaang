defmodule JaangWeb.Admin.Employees.Roles.EmployeeRoleIndexLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Admin.Account.Employee.EmployeeRole

  @impl true
  def mount(_params, _session, socket) do
    roles = EmployeeAccountManager.list_roles()
    has_roles = Enum.count(roles) > 0

    socket =
      assign(socket,
        current_page: "Employee roles",
        roles: roles,
        has_roles: has_roles
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    EmployeeAccountManager.get_employee_role(id)
    |> EmployeeAccountManager.delete_employee_role()

    roles = EmployeeAccountManager.list_roles()
    {:noreply, assign(socket, roles: roles)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Employee roles")
    |> assign(:role, nil)
  end

  defp apply_action(socket, :add, _params) do
    socket
    |> assign(:page_title, "Add employee roles")
    |> assign(:role, %EmployeeRole{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit employee roles")
    |> assign(:role, EmployeeAccountManager.get_employee_role(id))
  end
end
