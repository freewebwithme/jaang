defmodule JaangWeb.InvoiceChannel do
  @moduledoc """
  This channel for track current invoice(order) status

  """
  use Phoenix.Channel
  alias Jaang.InvoiceManager

  def join("invoice:" <> invoice_id, _params, %{assigns: %{current_user: user}} = socket) do
    # Check if current user is the owner of requested Order
    invoice = InvoiceManager.get_invoice_by_id(invoice_id)

    if user.id == invoice.user_id do
      # User is the owner of invoice.
      {:ok, %{event: "order confirmed", invoice_number: invoice.invoice_number}, socket}
    else
      {:error, %{reason: "unauthenticated"}}
    end
  end

  def join("invoice:" <> _invoice_id, _params, _socket) do
    IO.puts("Can't join a invoice channel")
    {:error, %{reason: "unauthenticated"}}
  end
end
