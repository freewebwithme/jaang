defmodule JaangWeb.Admin.CustomerServices.CustomerMessageLive.Search do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.CustomerServices
  alias JaangWeb.Admin.Components.FunctionComponents.CustomerMessageTableComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_page: "Customer message search result")}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    search_by_params = params["search_by"]
    search_term_params = params["search_term"]
    by_state = params["filter_by"] || "All"

    filter_by = %{by_state: by_state}

    filter_by_list = [
      "All",
      "In progress",
      "New request",
      "Completed"
    ]

    paginate_options = %{page: page, per_page: per_page}
    search_by = %{search_by: search_by_params, search_term: search_term_params}

    customer_messages =
      CustomerServices.list_customer_message(
        paginate: paginate_options,
        search_by: search_by,
        filter_by: filter_by
      )

    has_next_page = Helpers.has_next_page?(Enum.count(customer_messages), per_page)

    filter_by_default = params["filter_by"] || "All"

    search_by_list = ["Email"]

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        customer_messages: customer_messages,
        search_by_list: search_by_list,
        search_by: params["search_by"],
        search_term: params["search_term"],
        filter_by_list: filter_by_list,
        filter_by: filter_by_default
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    customer_messages =
      CustomerServices.list_customer_message(
        search_by: %{search_by: search_by, search_term: search_term}
      )

    has_next_page =
      Helpers.has_next_page?(Enum.count(customer_messages), socket.assigns.options.per_page)

    socket = assign(socket, customer_messages: customer_messages, has_next_page: has_next_page)

    socket =
      push_redirect(
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

  def handle_event("select-by-state", %{"by-state" => by_state}, socket) do

    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            has_next_page: socket.assigns.has_next_page,
            filter_by: by_state,
            search_by: socket.assigns.search_by,
            search_term: socket.assigns.search_term
          )
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.customer_messages), per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            has_next_page: has_next_page,
            search_by: socket.assigns.search_by,
            search_term: socket.assigns.search_term
          )
      )

    {:noreply, socket}
  end
end
