defmodule Jaang.Checkout.Checkout do
  alias Jaang.{ProfileManager, InvoiceManager, StripeManager, OrderManager}

  @doc """
  This function places an order using currently saved
  invoice schema, default address, phone number, default payment method.
  """
  def place_an_order(user) do
    # Get a default address
    address = ProfileManager.get_default_address(user.addresses)
    # Get an invoice
    invoice = InvoiceManager.get_invoice_in_cart(user.id)
    # Get a default payment method
    default_payment_method_id = StripeManager.get_default_payment_method(user.stripe_id)

    # Get a payment method detail
    {:ok, %{card: %{last4: last4}}} =
      StripeManager.retrieve_payment_method(default_payment_method_id)

    # Send a payment to stripe backend
    # Place a hold on a card
    case StripeManager.create_payment_intent(
           invoice.total.amount,
           user.stripe_id,
           default_payment_method_id
         ) do
      {:ok, payment_intent} ->
        IO.inspect(payment_intent.id)
        # Mark order as "confirmed"
        Enum.map(invoice.orders, fn order ->
          OrderManager.update_cart(order, %{status: :confirmed})
        end)

        # Update an invoice
        invoice =
          InvoiceManager.update_invoice(invoice, %{
            pm_intent_id: payment_intent.id,
            address_id: address.id,
            payment_method: "Ending with #{last4}",
            status: :completed
          })

        {:ok, invoice}

      {:error, error} ->
        IO.inspect(error)
        {:error, "Can't process a payment. Please try again later."}
    end
  end
end
