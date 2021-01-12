defmodule JaangWeb.InvoiceChannel do
  @moduledoc """
  This channel for place an order and track current invoice(order) status
  Place an order function returns Invoice schema , so I need to track invoice status
  """
  use Phoenix.Channel
  alias Jaang.{OrderManager, InvoiceManager}

  def join("invoice:" <> invoice_id, _params, %{assigns: %{current_user: user}} = socket) do
    # Check if current user is the owner of requested Order
    invoice = InvoiceManager.get_invoice_by_id(invoice_id)

    if(user.id == invoice.user_id) do
      # User is the owner of invoice.
      {:ok, socket}
    end

    {:error, %{reason: "unauthenticated"}}
  end

  def join("invoice:" <> _invoice_id, _params, _socket) do
    IO.puts("Can't join a invoice channel")
    {:error, %{reason: "unauthenticated"}}
  end

  def handle_info({:send_invoice, event}, socket) do
  end

  def handle_in("cancel_order", payload, socket) do
  end

  def handle_in("update_invoice_status", payload, socket) do
  end

  def handle_in("delivered_order", payload, socket) do
  end
end
