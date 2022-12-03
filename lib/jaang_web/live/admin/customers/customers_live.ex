defmodule JaangWeb.Admin.Customers.CustomersLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Customer.Customers
  alias JaangWeb.Admin.Customers.{CustomerDetailLive, CustomerSearchResultLive}

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [customers: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    customers = Customers.get_customers(paginate: paginate_options)

    has_next_page = Helpers.has_next_page?(Enum.count(customers), per_page)

    socket =
      assign(
        socket,
        has_next_page: has_next_page,
        options: paginate_options,
        customers: customers,
        current_page: "Customers"
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.customers), per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            has_next_page: has_next_page
          )
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    socket =
      push_navigate(
        socket,
        to:
          Routes.live_path(
            socket,
            CustomerSearchResultLive,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end
end
