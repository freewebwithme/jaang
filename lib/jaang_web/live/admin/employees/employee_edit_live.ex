defmodule JaangWeb.Admin.Employees.EmployeeEditLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias JaangWeb.Admin.Employees.EmployeesOverviewLive

  def mount(%{"id" => id}, _session, socket) do
    employee = EmployeeAccountManager.get_employee(id)
    IO.inspect(employee)
    changeset = EmployeeAccountManager.change_employee(employee, %{})
    roles = EmployeeAccountManager.list_roles()
    selected_roles = get_selected_roles(employee)

    socket =
      assign(socket,
        current_page: "Employee edit page",
        employee: employee,
        roles: roles,
        selected_roles: selected_roles,
        changeset: changeset,
        can_save: changeset.valid?
      )

    {:ok, socket}
  end

  defp get_selected_roles(employee) do
    selected_roles =
      if Enum.count(employee.roles) == 0 do
        ""
      else
        Enum.reduce(employee.roles, "", fn role, acc ->
          acc <> ", " <> role.name
        end)
      end

    selected_roles
  end
end
