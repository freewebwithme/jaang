defmodule Jaang.InvoiceManager do
  alias Jaang.Invoice.Invoices

  defdelegate create_invoice(user_id), to: Invoices
  defdelegate get_invoice_in_cart(user_id), to: Invoices
  defdelegate get_or_create_invoice(user_id), to: Invoices
  defdelegate update_invoice(invoice, attrs), to: Invoices

  @doc """
   Get confirmed invocies
  """
  defdelegate get_invoices(user_id), to: Invoices
end
