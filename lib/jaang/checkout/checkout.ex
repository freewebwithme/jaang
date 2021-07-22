defmodule Jaang.Checkout.Checkout do
  alias Jaang.{ProfileManager, InvoiceManager, StripeManager, OrderManager}
  alias Jaang.Store.DeliveryDateTimes

  def make_payment(user, grand_total, default_payment_method_id) do
    # Send a payment to stripe backend
    # Place a hold on a card
    StripeManager.create_payment_intent(
      grand_total,
      user.stripe_id,
      default_payment_method_id
    )
  end

  @doc """
  This function places an order using currently saved
  invoice schema, default address, phone number, default payment method.
  Get delivery time from client.
  """

  def place_an_order(order_infos, user) do
    carts = OrderManager.get_all_carts(user.id)
    grand_total_price = OrderManager.calculate_grand_total_price(carts)
    default_payment_method_id = StripeManager.get_default_payment_method(user.stripe_id)

    # Get a payment method detail
    {:ok, %{card: %{last4: last4}}} =
      StripeManager.retrieve_payment_method(default_payment_method_id)

    case make_payment(user, grand_total_price.amount, default_payment_method_id) do
      {:ok, payment_intent} ->
        # Get current datetime
        order_placed_at = DateTime.utc_now() |> DateTime.truncate(:second)

        # Update Order(cart) with each order info
        Enum.map(order_infos, fn order_info ->
          %{
            "deliveryAddress" => delivery_address,
            "deliverySchedule" => delivery_time,
            "orderId" => order_id,
            "phoneNumber" => phone_number,
            "storeId" => _store_id
          } = order_info

          # get delivery address id
          %{"id" => address_id} = delivery_address
          # get address
          address = ProfileManager.get_address(address_id)
          # Parse delivery_time
          {delivery_order, delivery_date} =
            DeliveryDateTimes.parse_delivery_datetime(delivery_time)

          # Get order(cart)
          order = OrderManager.get_cart(order_id)

          OrderManager.update_cart(order, %{
            order_placed_at: order_placed_at,
            status: :submitted,
            delivery_time: delivery_time,
            delivery_date: delivery_date,
            delivery_order: delivery_order,
            instruction: address.instructions,
            recipient: address.recipient,
            address_line_one: address.address_line_one,
            address_line_two: address.address_line_two,
            business_name: address.business_name,
            zipcode: address.zipcode,
            city: address.city,
            state: address.state,
            phone_number: phone_number
          })
        end)

        # then update invoice
        invoice = InvoiceManager.get_invoice_in_cart(user.id)

        # Calculate total items
        total_items = OrderManager.count_total_item(invoice.orders)

        InvoiceManager.update_invoice(invoice, %{
          pm_intent_id: payment_intent.id,
          payment_method: "Ending with #{last4}",
          status: :submitted,
          total_items: total_items,
          grand_total_price: grand_total_price,
          invoice_placed_at: order_placed_at
        })

      {:error, error} ->
        IO.inspect(error)
        {:error, "Can't process a payment. Please try again later."}
    end
  end
end
