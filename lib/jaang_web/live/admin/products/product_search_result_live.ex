defmodule JaangWeb.Admin.Products.ProductSearchResultLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Product.Products
  alias JaangWeb.Admin.Products.ProductDetailLive

  def mount(
        %{
          "store_id" => store_id,
          "store_name" => store_name,
          "search_by" => search_by,
          "search_term" => term
        } = params,
        _session,
        socket
      ) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    filter_by = params["filter_by"] || "All"

    products =
      Products.get_products(store_id,
        paginate: paginate_options,
        filter_by: %{by_state: filter_by},
        search_by: %{search_by: search_by, search_term: term}
      )

    number_of_result = Enum.count(products)

    has_next_page = Helpers.has_next_page?(number_of_result, per_page)

    socket =
      assign(socket,
        store_id: store_id,
        store_name: store_name,
        has_next_page: has_next_page,
        options: paginate_options,
        products: products,
        current_page: "Products Search Result",
        filter_by: filter_by,
        search_by: search_by,
        search_term: term
      )

    {:ok, socket}
  end

  def handle_params(%{"store_name" => store_name, "store_id" => store_id} = params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    by_state = params["filter_by"] || "All"
    filter_by_options = %{by_state: by_state}

    search_by = params["search_by"] || "Name"
    search_term = params["search_term"] || ""
    search_options = %{search_by: search_by, search_term: search_term}

    products =
      Products.get_products(store_id,
        paginate: paginate_options,
        filter_by: filter_by_options,
        search_by: search_options
      )

    number_of_result = Enum.count(products)

    has_next_page = Helpers.has_next_page?(number_of_result, paginate_options.per_page)

    socket =
      assign(
        socket,
        current_page: "Products Search result",
        store_name: store_name,
        store_id: store_id,
        filter_by: by_state,
        options: paginate_options,
        has_next_page: has_next_page,
        products: products,
        search_by: search_by,
        search_term: search_term
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
            has_next_page: has_next_page,
            search_by: socket.assigns.search_by,
            search_term: socket.assigns.search_term
          )
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
            filter_by: by_state,
            search_by: socket.assigns.search_by,
            search_term: socket.assigns.search_term
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
            socket.assigns.store_name,
            store_id: socket.assigns.store_id,
            store_name: socket.assigns.store_name,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            filter_by: socket.assigns.filter_by,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end
end
