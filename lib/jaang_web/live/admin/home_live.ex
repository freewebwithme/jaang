defmodule JaangWeb.Admin.HomeLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [unfulfilled_invoicesf: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")

    paginate_options = %{page: page, per_page: per_page}
    unfulfilled_invoices = Invoices.get_unfulfilled_invoices(paginate: paginate_options)

    socket = assign(socket, options: paginate_options, unfulfilled_orders: unfulfilled_invoices)

    {:noreply, socket}
  end

  defp display_money(%Money{} = money) do
    Money.to_string(money)
  end

  defp capitalize_text(text) do
    text = Atom.to_string(text)
    String.capitalize(text, :default)
  end
end
