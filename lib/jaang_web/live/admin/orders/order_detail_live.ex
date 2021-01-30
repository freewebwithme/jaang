defmodule JaangWeb.Admin.Orders.OrderDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices

  def mount(%{"id" => invoice_id}, _session, socket) do
    invoice = Invoices.get_invoice(invoice_id)

    socket =
      assign(
        socket,
        current_page: "Order Detail",
        invoice: invoice
      )

    {:ok, socket}
  end
end
