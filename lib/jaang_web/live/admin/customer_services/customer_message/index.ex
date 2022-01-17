defmodule JaangWeb.Admin.CustomerServices.CustomerMessageLive.Index do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.CustomerServices
  alias JaangWeb.Admin.Components.FunctionComponents.CustomerMessageTableComponent

  def mount(_params, _session, socket) do
    if connected?(socket), do: CustomerServices.subscribe()

    socket = assign(socket, current_page: "Customer message")
    {:ok, socket, temporary_assigns: [customer_messages: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    filter_by = %{by_state: by_state}

    customer_messages =
      CustomerServices.list_customer_message(paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(customer_messages), per_page)

    filter_by_list = [
      "All",
      "In progress",
      "New request",
      "Completed"
    ]

    filter_by_default = params["filter_by"] || "All"
    search_by_list = ["Email"]
    search_by_default = "Email"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        customer_messages: customer_messages,
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
    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.customer_messages), per_page)

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

  def handle_event("select-by-state", %{"by-state" => by_state}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            has_next_page: socket.assigns.has_next_page,
            filter_by: by_state
          )
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    socket =
      push_redirect(
        socket,
        to:
          Routes.live_path(
            socket,
            JaangWeb.Admin.CustomerServices.CustomerMessageLive.Search,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end

  def handle_info({:new_customer_message, customer_message}, socket) do
    IO.puts("New customer message came in")
    IO.inspect(socket.assigns)

    socket =
      update(socket, :customer_messages, fn customer_messages ->
        IO.inspect(Enum.count(customer_messages))
        [customer_message | customer_messages]
      end)

    IO.inspect(Enum.count(socket.assigns.customer_messages))
    {:noreply, socket}
  end
end
