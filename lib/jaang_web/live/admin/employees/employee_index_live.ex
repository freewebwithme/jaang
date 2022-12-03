defmodule JaangWeb.Admin.Employees.EmployeeIndexLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias Jaang.Admin.Account.Employee.Employee
  alias JaangWeb.Admin.Employees.EmployeeDetailLive
  alias JaangWeb.Admin.Employees.EmployeesOverviewLive
  alias Jaang.StoreManager

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
    # Get roles ids

    changeset =
      if socket.assigns.live_action == :edit do
        EmployeeAccountManager.change_employee(socket.assigns.employee, attrs)
        |> Map.put(:action, :insert)
      else
        EmployeeAccountManager.registration_change_employee(attrs)
        |> Map.put(:action, :insert)
      end

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    EmployeeAccountManager.get_employee(id)
    |> EmployeeAccountManager.delete_employee()

    socket =
      socket
      |> push_navigate(to: Routes.live_path(socket, EmployeesOverviewLive))
      |> put_flash(:info, "Employee is deleted successfully")

    {:noreply, socket}
  end

  # Changing both employee roles and assigned stores
  def handle_event(
        "save",
        %{
          "employee" => %{"roles_ids" => _roles_ids, "stores_ids" => _stores_ids} = employee_attrs
        },
        socket
      ) do
    roles = find_selected_roles(socket, employee_attrs)
    stores = find_selected_assigned_stores(socket, employee_attrs)

    if socket.assigns.live_action == :edit do
      EmployeeAccountManager.change_employee(socket.assigns.employee, employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset(roles)
      |> EmployeeAccountManager.put_assigned_stores_in_changeset(stores)
      |> EmployeeAccountManager.update_employee()

      {:noreply, put_flash_and_redirect_for_edit_action(socket)}
    else
      # Add a new employee
      EmployeeAccountManager.registration_change_employee(employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset(roles)
      |> EmployeeAccountManager.put_assigned_stores_in_changeset(stores)
      |> EmployeeAccountManager.create_employee()

      {:noreply, put_flash_and_redirect_for_add_action(socket)}
    end
  end

  # Changing employee role but not assigned stores
  # No selection in assigned stores, so Delete assigned stores from employee
  @impl true
  def handle_event("save", %{"employee" => %{"roles_ids" => _roles_ids} = employee_attrs}, socket) do
    roles = find_selected_roles(socket, employee_attrs)

    if socket.assigns.live_action == :edit do
      EmployeeAccountManager.change_employee(socket.assigns.employee, employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset(roles)
      |> EmployeeAccountManager.put_assigned_stores_in_changeset([])
      |> EmployeeAccountManager.update_employee()

      {:noreply, put_flash_and_redirect_for_edit_action(socket)}
    else
      # Add a new employee
      EmployeeAccountManager.registration_change_employee(employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset(roles)
      |> EmployeeAccountManager.put_assigned_stores_in_changeset([])
      |> EmployeeAccountManager.create_employee()

      {:noreply, put_flash_and_redirect_for_add_action(socket)}
    end
  end

  # Changing assigned store but not employee role
  # No selection in roles, so Delete roles from employee
  def handle_event(
        "save",
        %{"employee" => %{"stores_ids" => _stores_ids} = employee_attrs},
        socket
      ) do
    IO.puts("No selection for roles. So Delete current roles from employee")
    stores = find_selected_assigned_stores(socket, employee_attrs)

    if socket.assigns.live_action == :edit do
      EmployeeAccountManager.change_employee(socket.assigns.employee, employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset([])
      |> EmployeeAccountManager.put_assigned_stores_in_changeset(stores)
      |> EmployeeAccountManager.update_employee()

      {:noreply, put_flash_and_redirect_for_edit_action(socket)}
    else
      # Add a new employee
      EmployeeAccountManager.registration_change_employee(employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset([])
      |> EmployeeAccountManager.put_assigned_stores_in_changeset(stores)
      |> EmployeeAccountManager.create_employee()

      {:noreply, put_flash_and_redirect_for_add_action(socket)}
    end
  end

  # Changing not employee roles and not assigned stores
  # This tells that uncheck all employee roles and assigned stores
  # So delete roles and assiged stores
  def handle_event("save", %{"employee" => employee_attrs}, socket) do
    IO.puts(
      "No selection for both roles and assigned stores. So Delete both current roles and assigned stores"
    )

    if socket.assigns.live_action == :edit do
      EmployeeAccountManager.change_employee(socket.assigns.employee, employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset([])
      |> EmployeeAccountManager.put_assigned_stores_in_changeset([])
      |> EmployeeAccountManager.update_employee()

      {:noreply, put_flash_and_redirect_for_edit_action(socket)}
    else
      # Add a new employee
      EmployeeAccountManager.registration_change_employee(employee_attrs)
      |> EmployeeAccountManager.put_roles_in_changeset([])
      |> EmployeeAccountManager.put_assigned_stores_in_changeset([])
      |> EmployeeAccountManager.create_employee()

      {:noreply, put_flash_and_redirect_for_add_action(socket)}
    end
  end

  @doc """
  Handle message from active toggle component
  """
  @impl true
  def handle_info({:updated_employee, updated_employee}, socket) do
    changeset = EmployeeAccountManager.change_employee(updated_employee, %{})
    socket = assign(socket, changeset: changeset, employee: updated_employee)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_employee_error, changeset}, socket) do
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  defp find_selected_roles(socket, employee_attrs) do
    # Get roles_ids and convert to integer
    roles_ids = Map.fetch!(employee_attrs, "roles_ids") |> Enum.map(&String.to_integer(&1))
    # get roles from assigns
    Enum.filter(socket.assigns.roles, &(&1.id in roles_ids))
  end

  defp find_selected_assigned_stores(socket, employee_attrs) do
    # Get stores_ids and conver to integer
    stores_ids = Map.fetch!(employee_attrs, "stores_ids") |> Enum.map(&String.to_integer(&1))
    # get stores from assigns
    Enum.filter(socket.assigns.stores, &(&1.id in stores_ids))
  end

  defp put_flash_and_redirect_for_edit_action(socket) do
    socket
    |> put_flash(:info, "Employee is updated successfully")
    |> push_navigate(to: Routes.live_path(socket, EmployeeDetailLive, socket.assigns.employee.id))
  end

  defp put_flash_and_redirect_for_add_action(socket) do
    socket
    |> put_flash(:info, "Employee is created successfully")
    |> push_navigate(to: Routes.live_path(socket, EmployeesOverviewLive))
  end

  def employee_has_role?(employee, role) do
    role in employee.roles
  end

  def employee_has_assigned_store?(employee, store) do
    store in employee.assigned_stores
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    employee = EmployeeAccountManager.get_employee(id)
    roles = EmployeeAccountManager.list_roles()
    changeset = EmployeeAccountManager.change_employee(employee, %{})
    stores = StoreManager.get_all_stores()

    socket
    |> assign(:employee, employee)
    |> assign(:changeset, changeset)
    |> assign(:roles, roles)
    |> assign(:stores, stores)
    |> assign(:can_save, changeset.valid?)
    |> assign(:page_title, "Edit employee")
  end

  defp apply_action(socket, :add, _params) do
    roles = EmployeeAccountManager.list_roles()
    changeset = EmployeeAccountManager.change_employee(%Employee{}, %{})
    stores = StoreManager.get_all_stores()
    IO.inspect(changeset)

    socket
    |> assign(:employee, %Employee{})
    |> assign(:changeset, changeset)
    |> assign(:roles, roles)
    |> assign(:stores, stores)
    |> assign(:can_save, changeset.valid?)
    |> assign(:page_title, "Add employee")
  end
end
