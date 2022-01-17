defmodule JaangWeb.Admin.Invoices.InvoiceLive.Search do
  use JaangWeb, :dashboard_live_view
  alias JaangWeb.Admin.Components.FunctionComponents.InvoiceTableComponent
  alias Jaang.Admin.Invoice.Invoices

  def mount(_params, _session, socket) do
    IO.puts("Calling invoice search result")
    {:ok, assign(socket, current_page: "Invoice search result")}
  end

  def handle_params(params, _url, socket) do
    IO.puts("Calling Invoice search result handle-params")
    IO.inspect(params)
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    search_by_params = params["search_by"]
    search_term_params = params["search_term"]

    paginate_options = %{page: page, per_page: per_page}
    search_by = %{search_by: search_by_params, search_term: search_term_params}

    invoices =
      Invoices.get_invoices(
        paginate: paginate_options,
        search_by: search_by
      )

    has_next_page = Helpers.has_next_page?(Enum.count(invoices), per_page)

    search_by_list = ["Invoice id"]

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        invoices: invoices,
        search_by_list: search_by_list,
        search_by: params["search_by"],
        search_term: params["search_term"]
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    invoices = Invoices.get_invoices(search_by: %{search_by: search_by, search_term: search_term})
    has_next_page = Helpers.has_next_page?(Enum.count(invoices), socket.assigns.options.per_page)
    socket = assign(socket, invoices: invoices, has_next_page: has_next_page)

    socket =
      push_redirect(
        socket,
        to:
          Routes.live_path(
            socket,
            JaangWeb.Admin.Invoices.InvoiceLive.Search,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    IO.puts("Calling handle_event: select-per-page")
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
end
