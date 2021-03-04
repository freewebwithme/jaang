defmodule JaangWeb.Admin.Employees.EmployeeIndexLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Admin.Account.Employee.Employee
  alias JaangWeb.Admin.Employees.EmployeeDetailLive
  alias JaangWeb.Admin.Employees.EmployeesOverviewLive
  alias __MODULE__

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        current_page: "Employee edit/add page"
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"employee" => attrs}, socket) do
    IO.inspect(attrs)
    # Get roles ids

    changeset =
      if(socket.assigns.live_action == :edit) do
        EmployeeAccountManager.change_employee(socket.assigns.employee, attrs)
        |> Map.put(:action, :insert)
      else
        EmployeeAccountManager.registration_change_employee(attrs)
        |> Map.put(:action, :insert)
      end

    IO.inspect(changeset)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  @impl true
  def handle_event("save", %{"employee" => employee_attrs}, socket) do
    IO.inspect(employee_attrs)

    case Map.has_key?(employee_attrs, "roles_ids") do
      true ->
        # Get ids and convert to integer
        roles_ids = Map.fetch!(employee_attrs, "roles_ids") |> Enum.map(&String.to_integer(&1))
        # get roles from assigns
        roles = Enum.filter(socket.assigns.roles, &(&1.id in roles_ids))
        IO.inspect(roles)

        if(socket.assigns.live_action == :edit) do
          EmployeeAccountManager.change_employee(socket.assigns.employee, employee_attrs)
          |> EmployeeAccountManager.put_roles_in_changeset(roles)
          |> EmployeeAccountManager.update_employee()

          socket =
            socket
            |> put_flash(:info, "Employee is updated successfully")
            |> push_redirect(
              to: Routes.live_path(socket, EmployeeDetailLive, socket.assigns.employee.id)
            )

          {:noreply, socket}
        else
          # Add a new employee
          EmployeeAccountManager.registration_change_employee(employee_attrs)
          |> EmployeeAccountManager.put_roles_in_changeset(roles)
          |> EmployeeAccountManager.create_employee()

          socket =
            socket
            |> put_flash(:info, "Employee is created successfully")
            |> push_redirect(to: Routes.live_path(socket, EmployeesOverviewLive))

          {:noreply, socket}
        end

      _ ->
        # No selection for roles
        if(socket.assigns.live_action == :edit) do
          EmployeeAccountManager.change_employee(socket.assigns.employee, employee_attrs)
          |> EmployeeAccountManager.put_roles_in_changeset([])
          |> EmployeeAccountManager.update_employee()

          socket =
            socket
            |> put_flash(:info, "Employee is updated successfully")
            |> push_redirect(
              to: Routes.live_path(socket, EmployeeDetailLive, socket.assigns.employee.id)
            )

          {:noreply, socket}
        else
          # Add a new employee
          EmployeeAccountManager.registration_change_employee(employee_attrs)
          |> EmployeeAccountManager.put_roles_in_changeset([])
          |> EmployeeAccountManager.create_employee()

          socket =
            socket
            |> put_flash(:info, "Employee is created successfully")
            |> push_redirect(to: Routes.live_path(socket, EmployeesOverviewLive))

          {:noreply, socket}
        end
    end
  end

  def employee_has_role?(employee, role) do
    result = role in employee.roles
    IO.inspect(result)
    result
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    employee = EmployeeAccountManager.get_employee(id)
    roles = EmployeeAccountManager.list_roles()
    changeset = EmployeeAccountManager.change_employee(employee, %{})

    socket
    |> assign(:employee, employee)
    |> assign(:changeset, changeset)
    |> assign(:roles, roles)
    |> assign(:can_save, changeset.valid?)
    |> assign(:page_title, "Edit employee")
  end

  defp apply_action(socket, :add, _params) do
    roles = EmployeeAccountManager.list_roles()
    changeset = EmployeeAccountManager.change_employee(%Employee{}, %{})

    socket
    |> assign(:changeset, changeset)
    |> assign(:roles, roles)
    |> assign(:can_save, changeset.valid?)
    |> assign(:page_title, "Add employee")
  end
end
