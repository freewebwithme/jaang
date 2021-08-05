defmodule JaangWeb.Admin.Orders.OrderDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Order.Orders
  alias Jaang.Admin.Invoice.Invoices

  def mount(%{"id" => order_id}, _session, socket) do
    if connected?(socket), do: Jaang.Checkout.Carts.subscribe()

    order = Orders.get_order(order_id)
    invoice = Invoices.get_invoice(order.invoice_id)

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
        order: order,
        invoice: invoice,
        statuses: statuses,
        current_status: Helpers.convert_atom_and_string(order.status)
      )

    {:ok, socket}
  end

  def handle_event(
        "change_state",
        %{"order-status" => state, "order-id" => order_id},
        socket
      ) do
    # Change string to atom
    new_state = Helpers.convert_atom_and_string(state)
    {:ok, order} = Orders.update_order_and_notify(order_id, %{status: new_state}, new_state)

    socket =
      assign(
        socket,
        order: order,
        current_status: Helpers.convert_atom_and_string(order.status)
      )

    {:noreply, socket}
  end

  def handle_info({:order_updated, order}, socket) do
    IO.puts("Order is updated from OrderDetailLive: #{order.id}")

    socket =
      update(socket, :order, fn _order -> order end)
      |> update(:current_status, fn _invoice ->
        Helpers.convert_atom_and_string(order.status)
      end)

    {:noreply, socket}
  end

  def handle_info({:new_order, _order}, socket) do
    {:noreply, socket}
  end
end
