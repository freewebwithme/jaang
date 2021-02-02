defmodule JaangWeb.Admin.Home.HomeLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [invoices: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")

    paginate_options = %{page: page, per_page: per_page}
    invoices = Invoices.get_invoices(paginate: paginate_options)

    has_next_page = Helpers.has_next_page?(Enum.count(invoices), per_page)

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        invoices: invoices,
        current_page: "Home"
      )

    {:noreply, socket}
  end
end
