defmodule JaangWeb.Admin.Customers.CustomerSearchResultLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Customer.Customers
  alias JaangWeb.Admin.Customers.CustomerDetailLive

  def mount(%{"search_term" => term, "search_by" => search_by} = params, _session, socket) do

    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    customers =
      Customers.get_customers(
        paginate: paginate_options,
        search_by: %{search_by: search_by, search_term: term}
      )

    number_of_result = Enum.count(customers)

    has_next_page = Helpers.has_next_page?(number_of_result, per_page)

    socket =
      assign(
        socket,
        current_page: "Customer search result page",
        customers: customers,
        has_next_page: has_next_page,
        options: paginate_options,
        search_by: search_by,
        search_term: term
      )

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}
    search_by = params["search_by"] || "Email"
    search_term = params["search_term"] || ""
    search_options = %{search_by: search_by, search_term: search_term}

    customers =
      Customers.get_customers(
        paginate: paginate_options,
        search_by: search_options
      )

    number_of_result = Enum.count(customers)

    has_next_page = Helpers.has_next_page?(number_of_result, per_page)

    socket =
      assign(
        socket,
        customers: customers,
        has_next_page: has_next_page,
        options: paginate_options,
        search_by: search_by,
        search_term: search_term
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
      push_patch(
        socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end
end
