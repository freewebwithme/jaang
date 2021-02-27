defmodule JaangWeb.Admin.Orders.OrderDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices

  def mount(%{"id" => invoice_id}, _session, socket) do
    if connected?(socket), do: Jaang.Invoice.Invoices.subscribe()

    invoice = Invoices.get_invoice(invoice_id)

    statuses = [
      %{status: "Refunded", desc: "Invoice is refunded to customer"},
      %{status: "Submitted", desc: "Order just submitted"},
      %{status: "Shopping", desc: "Shopper is shopping your order"},
      %{status: "Packed", desc: "Order is ready to pick up by Driver"},
      %{status: "On_the_way", desc: "Order is on the way to customer"},
      %{status: "Delivered", desc: "Order is delivered"}
    ]

    socket =
      assign(
        socket,
        current_page: "Order Detail",
        invoice: invoice,
        statuses: statuses,
        current_status: Helpers.convert_atom_and_string(invoice.status)
      )

    {:ok, socket}
  end

  def handle_event(
        "change_state",
        %{"invoice-status" => state, "invoice-id" => invoice_id},
        socket
      ) do
    # Change string to atom
    new_state = Helpers.convert_atom_and_string(state)
    {:ok, invoice} = Invoices.update_invoice_status(invoice_id, new_state)

    socket =
      assign(
        socket,
        invoice: invoice,
        current_status: Helpers.convert_atom_and_string(invoice.status)
      )

    {:noreply, socket}
  end

  def handle_info({:invoice_updated, invoice}, socket) do
    IO.puts("Invoice is updated from OrderDetailLive: #{invoice.id}")

    socket =
      update(socket, :invoice, fn _invoice -> invoice end)
      |> update(:current_status, fn _invoice ->
        Helpers.convert_atom_and_string(invoice.status)
      end)

    {:noreply, socket}
  end

  def handle_info({:new_order, _invoice}, socket) do
    {:noreply, socket}
  end
end
