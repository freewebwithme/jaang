defmodule Jaang.Checkout.Checkout do
  alias Jaang.{ProfileManager, InvoiceManager, StripeManager, OrderManager}

  @doc """
  This function places an order using currently saved
  invoice schema, default address, phone number, default payment method.
  Get delivery time from client.
  """
  def place_an_order(user, delivery_time) do
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
        # Mark order as "submitted"
        Enum.map(invoice.orders, fn order ->
          OrderManager.update_cart(order, %{status: :submitted})
        end)

        # Calculate total items
        total_items = OrderManager.count_total_item(invoice.orders)
        # Update an invoice
        invoice =
          InvoiceManager.update_invoice(invoice, %{
            pm_intent_id: payment_intent.id,
            payment_method: "Ending with #{last4}",
            status: :submitted,
            total_items: total_items,
            # Add delivery address info
            recipient: address.recipient,
            address_line_one: address.address_line_one,
            address_line_two: address.address_line_two,
            business_name: address.business_name,
            zipcode: address.zipcode,
            city: address.city,
            state: address.state,
            instructions: address.instructions,
            phone_number: user.profile.phone,
            # Add delivery time
            delivery_time: delivery_time
          })

        {:ok, invoice}

      {:error, error} ->
        IO.inspect(error)
        {:error, "Can't process a payment. Please try again later."}
    end
  end
end
