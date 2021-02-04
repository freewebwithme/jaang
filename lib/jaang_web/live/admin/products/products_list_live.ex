defmodule JaangWeb.Admin.Products.ProductsListLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Product.Products
  alias JaangWeb.Admin.Products.ProductDetailLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"store_id" => store_id, "store_name" => store_name} = params, _url, socket) do
    IO.inspect(params)
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    filter_by = %{by_state: by_state}

    products = Products.get_products(store_id, paginate: paginate_options, filter_by: filter_by)
    has_next_page = Helpers.has_next_page?(Enum.count(products), per_page)

    socket =
      assign(socket,
        store_id: store_id,
        store_name: store_name,
        has_next_page: has_next_page,
        options: paginate_options,
        products: products,
        current_page: "Products List",
        filter_by: by_state,
        temporary_assigns: [products: []]
      )

    {:noreply, socket}
  end

  def handle_event("select-by-state", %{"by-state" => by_state}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            socket.assigns.store_name,
            store_id: socket.assigns.store_id,
            store_name: socket.assigns.store_name,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            has_next_page: socket.assigns.has_next_page,
            filter_by: by_state
          )
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.products), per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            socket.assigns.store_name,
            store_id: socket.assigns.store_id,
            store_name: socket.assigns.store_name,
            page: socket.assigns.options.page,
            per_page: per_page,
            has_next_page: has_next_page
          )
      )

    {:noreply, socket}
  end
end
