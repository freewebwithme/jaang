defmodule JaangWeb.Admin.Employees.Roles.EmployeeRolesLive do
  use JaangWeb, :dashboard_live_view
  alias JaangWeb.Admin.Employees.Roles.{EmployeeRoleAddLive, EmployeeRoleEditLive}
  alias Jaang.Admin.EmployeeAccountManager

  def mount(_params, _session, socket) do
    roles = EmployeeAccountManager.list_roles()
    has_roles = Enum.count(roles) > 0
    socket = assign(socket, current_page: "Employee roles", roles: roles, has_roles: has_roles)
    {:ok, socket}
  end
end
