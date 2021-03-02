defmodule JaangWeb.Admin.Employees.Roles.EmployeeRoleAddLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Account.Employee.EmployeeRole
  alias Jaang.Admin.EmployeeAccountManager
  alias JaangWeb.Admin.Employees.Roles.EmployeeRolesLive

  def mount(_params, _session, socket) do
    changeset = EmployeeRole.changeset(%EmployeeRole{}, %{})

    socket =
      assign(socket, current_page: "Employee role add", changeset: changeset, can_save: false)

    {:ok, socket}
  end

  def handle_event("validate", %{"employee_role" => attrs}, socket) do
    changeset =
      EmployeeAccountManager.change_employee_role(%EmployeeRole{}, attrs)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset, can_save: changeset.valid?)
    {:noreply, socket}
  end

  def handle_event("add_role", %{"employee_role" => attrs}, socket) do
    IO.inspect(attrs)

    case EmployeeAccountManager.create_employee_role(attrs) do
      {:ok, _employee} ->
        IO.puts("role created")

        socket =
          push_redirect(socket, to: Routes.live_path(socket, EmployeeRolesLive))
          |> put_flash(:info, "New roles added successfully")

        {:noreply, socket}

      {:error, changeset} ->
        IO.puts("role create fail")
        {:noreply, assign(socket, changeset: changeset, can_save: changeset.valid?)}
    end
  end
end
