defmodule JaangWeb.Admin.Home.HomeLive do
  use JaangWeb, :dashboard_live_view

  alias Jaang.Admin.Order.Orders
  alias JaangWeb.Admin.Components.FunctionComponents.OrderTableComponent
  alias JaangWeb.Admin.Orders.OrderSearchResultLive
  alias JaangWeb.Admin.Helpers

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [orders: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}

    orders = Orders.get_orders(paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(orders), per_page)

    filter_by_list = [
      "All",
      "Cart",
      "Refunded",
      "Partially_refunded",
      "Submitted",
      "Shopping",
      "Packed",
      "On_the_way",
      "Delivered"
    ]

    filter_by_default = params["filter_by"] || "All"

    search_by_list = ["Order id"]
    search_by_default = "Order Id"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        orders: orders,
        current_page: "Dashboard",
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
    socket =
      push_navigate(
        socket,
        to:
          Routes.live_path(
            socket,
            OrderSearchResultLive,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end

  def handle_info({:order_updated, order}, socket) do
    IO.puts(":order updated handle info calling from OrdersLive")
    socket = update(socket, :orders, fn orders -> [order | orders] end)
    {:noreply, socket}
  end

  def handle_info({:new_order, order}, socket) do
    socket = update(socket, :orders, fn orders -> [order | orders] end)
    {:noreply, socket}
  end
end
