defmodule JaangWeb.Admin.Employees.EmployeeDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.EmployeeAccountManager
  alias JaangWeb.Admin.Components.InvoiceComponent
  alias JaangWeb.Admin.Employees.EmployeeEditLive

  def mount(%{"id" => id} = _params, _session, socket) do
    employee = EmployeeAccountManager.get_employee(id)

    socket =
      assign(socket,
        current_page: "Employee detail page",
        page_title: "Employee detail",
        employee: employee
      )

    {:ok, socket}
  end
end
