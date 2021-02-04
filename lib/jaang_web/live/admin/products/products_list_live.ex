defmodule JaangWeb.Admin.Products.ProductsListLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Product.Products
  alias JaangWeb.Admin.Products.ProductDetailLive
  alias JaangWeb.Admin.Products.ProductSearchResultLive

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [products: []]}
  end

  # Handle params for filter by
  def handle_params(
        %{"store_id" => store_id, "store_name" => store_name, "filter_by" => by_state} = params,
        _url,
        socket
      ) do
    IO.puts("Calling filter by handle_params")

    filter_by = %{by_state: by_state}
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    products =
      Products.get_products(store_id,
        paginate: paginate_options,
        filter_by: filter_by
      )

    has_next_page = Helpers.has_next_page?(Enum.count(products), per_page)

    socket =
      assign(socket,
        store_id: store_id,
        store_name: store_name,
        has_next_page: has_next_page,
        products: products,
        current_page: "Products List",
        filter_by: by_state,
        options: paginate_options
      )

    {:noreply, socket}
  end

  # Handle params for page and per page
  def handle_params(
        %{
          "store_id" => store_id,
          "store_name" => store_name,
          "page" => page,
          "per_page" => per_page
        } = params,
        _url,
        socket
      ) do
    IO.puts("Calling per_page by handle_params")

    page = String.to_integer(page)
    per_page = String.to_integer(per_page)
    paginate_options = %{page: page, per_page: per_page}
    filter_by = params["filter_by"] || "All"

    products =
      Products.get_products(store_id,
        paginate: paginate_options,
        filter_by: %{by_state: filter_by}
      )

    has_next_page = Helpers.has_next_page?(Enum.count(products), per_page)

    socket =
      assign(socket,
        store_id: store_id,
        store_name: store_name,
        has_next_page: has_next_page,
        options: paginate_options,
        products: products,
        current_page: "Products List",
        filter_by: filter_by
      )

    {:noreply, socket}
  end

  # Catch all handle_params
  def handle_params(%{"store_id" => store_id, "store_name" => store_name} = params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    products = Products.get_products(store_id, paginate: paginate_options)
    has_next_page = Helpers.has_next_page?(Enum.count(products), paginate_options.per_page)

    socket =
      assign(
        socket,
        current_page: "Products List",
        store_name: store_name,
        store_id: store_id,
        filter_by: "All",
        options: paginate_options,
        has_next_page: has_next_page,
        products: products
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

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    socket =
      push_redirect(
        socket,
        to:
          Routes.live_path(
            socket,
            ProductSearchResultLive,
            socket.assigns.store_name,
            store_id: socket.assigns.store_id,
            store_name: socket.assigns.store_name,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end
end
