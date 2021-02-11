defmodule JaangWeb.Admin.Orders.OrderSearchResultLive do
  use JaangWeb, :dashboard_live_view
  alias JaangWeb.Admin.Components.OrderTableComponent
  alias Jaang.Admin.Invoice.Invoices

  def mount(%{"search_term" => term, "search_by" => search_by} = params, _session, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")

    paginate_options = %{page: page, per_page: per_page}

    socket =
      assign(
        socket,
        options: paginate_options
      )

    socket = search_invoices(socket, search_by, term)
    socket = assign(socket, current_page: "Order search result")
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}

    invoices = Invoices.get_invoices(paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(invoices), per_page)

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

    search_by_list = ["Invoice number"]
    search_by_default = "Invoice number"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        invoices: invoices,
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

    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.invoices), per_page)

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
    socket = search_invoices(socket, search_by, search_term)

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

  defp search_invoices(socket, search_by, search_term) do
    invoices = Invoices.get_invoices(search_by: %{search_by: search_by, search_term: search_term})
    has_next_page = Helpers.has_next_page?(Enum.count(invoices), socket.assigns.options.per_page)

    socket =
      assign(
        socket,
        invoices: invoices,
        has_next_page: has_next_page
      )

    socket
  end
end
