defmodule JaangWeb.Admin.Partners.PartnerLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Store.Stores
  alias Jaang.Admin.Order.Orders

  def mount(%{"store_id" => store_id}, _session, socket) do
    # Get store information
    store = Stores.get_store(store_id)

    orders = Orders.get_orders(store_id, paginate: %{page: 1, per_page: 10})

    socket =
      assign(socket,
        current_page: store.name,
        store_name: store.name,
        store_logo: store.store_logo,
        store_id: store.id,
        orders: orders
      )

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}

    orders =
      Orders.get_orders(socket.assigns.store_id, paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(orders), per_page)

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        orders: orders,
        current_page: socket.assigns.current_page,
        filter_by: by_state
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.orders), per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__, socket.assigns.store_id,
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
          Routes.live_path(socket, __MODULE__, socket.assigns.store_id,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            has_next_page: socket.assigns.has_next_page,
            filter_by: by_state
          )
      )

    {:noreply, socket}
  end
end
