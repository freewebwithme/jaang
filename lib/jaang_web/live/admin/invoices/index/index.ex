defmodule JaangWeb.Admin.Invoices.InvoiceLive.Index do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices
  alias JaangWeb.Admin.Components.InvoiceTableComponent

  def mount(_params, _session, socket) do
    if connected?(socket), do: Jaang.Invoice.Invoices.subscribe()
    {:ok, socket, temporary_assigns: [invoices: []]}
  end

  def handle_params(params, _url, socket) do
    IO.puts("Calling handle_params from InvoicesLive.Index")
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

    filter_by_default = params["filter_by"] || "All"

    search_by_list = ["Invoice id", "Email"]
    search_by_default = "Invoice Id"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        invoices: invoices,
        current_page: "Invoices",
        filter_by: filter_by_default,
        filter_by_list: filter_by_list,
        search_by_list: search_by_list,
        search_by: search_by_default
      )

    {:noreply, socket}
  end

  def handle_info({:invoice_updated, invoice}, socket) do
    IO.puts("invoice updated handle info call from Invoice live page")
    socket = update(socket, :invoices, fn invoices -> [invoice | invoices] end)
    {:noreply, socket}
  end

  def handle_info({:new_invoice, invoice}, socket) do
    IO.puts("New invoice handle info call from Invoice live page")
    socket = update(socket, :invoices, fn invoices -> [invoice | invoices] end)
    {:noreply, socket}
  end
end
