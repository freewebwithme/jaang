defmodule JaangWeb.Admin.Invoices.InvoiceLive.Show do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices

  def mount(%{"id" => invoice_id} = _params, _session, socket) do
    invoice = Invoices.get_invoice(invoice_id)

    {:ok, invoice_placed_at} =
      Jaang.Utility.convert_and_format_datetime(invoice.invoice_placed_at)

    {:ok,
     assign(socket,
       current_page: "Invoice Detail",
       invoice: invoice,
       invoice_placed_at: invoice_placed_at
     )}
  end
end
