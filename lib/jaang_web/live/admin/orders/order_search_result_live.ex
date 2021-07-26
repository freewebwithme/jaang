defmodule JaangWeb.Admin.Orders.OrderSearchResultLive do
  use JaangWeb, :dashboard_live_view
  alias JaangWeb.Admin.Components.OrderTableComponent
  alias Jaang.Admin.Order.Orders

  def mount(_params, _session, socket) do
    IO.puts("Calling Order search result mount")
    socket = assign(socket, current_page: "Order search result")
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    IO.puts("Calling Order search result handle-params")
    IO.inspect(params)
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"
    search_by_params = params["search_by"]
    search_term_params = params["search_term"]

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}
    search_by = %{search_by: search_by_params, search_term: search_term_params}

    orders =
      Orders.get_orders(paginate: paginate_options, filter_by: filter_by, search_by: search_by)

    has_next_page = Helpers.has_next_page?(Enum.count(orders), per_page)

    filter_by_list = [
      "All",
      "Cart",
      "Refunded",
      "Submitted",
      "Shopping",
      "Packed",
      "On_the_way",
      "Delivered"
    ]

    filter_by_default = "ALL"

    search_by_list = ["Order id"]
    search_by_default = "Order id"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        orders: orders,
        current_page: "Orders",
        filter_by: filter_by_default,
        filter_by_list: filter_by_list,
        search_by_list: search_by_list,
        search_by: search_by_default
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.orders), per_page)

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
    socket = search_orders(socket, search_by, search_term)

    socket =
      push_patch(
        socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            filter_by: socket.assigns.filter_by,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end

  defp search_orders(socket, search_by, search_term) do
    orders = Orders.get_orders(search_by: %{search_by: search_by, search_term: search_term})
    IO.puts("Printing orders result")
    IO.inspect(Enum.count(orders))
    has_next_page = Helpers.has_next_page?(Enum.count(orders), socket.assigns.options.per_page)

    socket =
      assign(
        socket,
        orders: orders,
        has_next_page: has_next_page
      )

    socket
  end
end
