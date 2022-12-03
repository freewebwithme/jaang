defmodule JaangWeb.Admin.Employees.EmployeesOverviewLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias JaangWeb.Admin.Components.FunctionComponents.EmployeeComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    role = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    filter_by = %{by_role: role}

    employees =
      EmployeeAccountManager.list_employees(paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(employees), per_page)

    filter_by_list = [
      "All",
      "Shopper",
      "Driver"
    ]

    filter_by_default = params["filter_by"] || "All"

    search_by_list = ["Name", "Email"]
    search_by_default = "Name"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        employees: employees,
        current_page: "Employee Overview",
        filter_by: filter_by_default,
        filter_by_list: filter_by_list,
        search_by_list: search_by_list,
        search_by: search_by_default
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    IO.puts("Calling handle_event: select-per-page")
    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.employees), per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            has_next_page: has_next_page
          )
      )

    {:noreply, socket}
  end

  def handle_event("select-by-role", %{"by-role" => by_role}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            has_next_page: socket.assigns.has_next_page,
            filter_by: by_role
          )
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    # socket =
    #  push_navigate(
    #    socket,
    #    to:
    #      Routes.live_path(
    #        socket,
    #        # TODO: Create Employee search result page
    #        OrderSearchResultLive,
    #        search_by: search_by,
    #        search_term: search_term
    #      )
    #  )
    {:noreply, socket}
  end

  @doc """
  Get a list of roles and display names
  """
  def display_roles(roles) when is_list(roles) do
    if Enum.count(roles) == 0 do
      "Not assigned"
    else
      role_names = ""

      Enum.reduce(roles, role_names, fn role, acc ->
        if acc == "" do
          acc <> role.name
        else
          acc <> ", " <> role.name
        end
      end)
    end
  end
end
