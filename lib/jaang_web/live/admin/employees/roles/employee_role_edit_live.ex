defmodule JaangWeb.Admin.Employees.Roles.EmployeeRoleEditLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias JaangWeb.Admin.Employees.Roles.EmployeeRolesLive

  def mount(%{"id" => id} = _params, _session, socket) do
    employee_role = EmployeeAccountManager.get_employee_role(id)
    changeset = EmployeeAccountManager.change_employee_role(employee_role, %{})

    socket =
      assign(socket,
        current_page: "Employee role edit",
        employee_role: employee_role,
        changeset: changeset,
        can_save: changeset.valid?
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"employee_role" => attrs}, socket) do
    changeset =
      EmployeeAccountManager.change_employee_role(socket.assigns.employee_role, attrs)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset, can_save: changeset.valid?)
    {:noreply, socket}
  end

  def handle_event("edit_role", %{"employee_role" => attrs}, socket) do
    IO.inspect(attrs)

    case EmployeeAccountManager.update_employee_role(socket.assigns.employee_role, attrs) do
      {:ok, _employee} ->
        IO.puts("role updated")

        socket =
          push_redirect(socket, to: Routes.live_path(socket, EmployeeRolesLive))
          |> put_flash(:info, "role updated successfully")

        {:noreply, socket}

      {:error, changeset} ->
        IO.puts("role update fail")
        {:noreply, assign(socket, changeset: changeset, can_save: changeset.valid?)}
    end
  end

  def handle_event("delete", _, socket) do
    case EmployeeAccountManager.delete_employee_role(socket.assigns.employee_role) do
      {:ok, _employee_role} ->
        socket =
          push_redirect(socket, to: Routes.live_path(socket, EmployeeRolesLive))
          |> put_flash(:info, "Role is deleted")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset, can_save: changeset.valid?)}
    end
  end
end
