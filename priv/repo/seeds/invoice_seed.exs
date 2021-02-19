alias Jaang.Checkout.Carts
alias Jaang.Checkout.Order
alias Jaang.Invoice.Invoices
# Create order(cart)
# loop through each user
statuses = [
  :submitted,
  :shopping,
  :packed,
  :on_the_way,
  :delivered
]

driver_tips = [
  100,
  200,
  300,
  150,
  400,
  450,
  500
]

subtotals = [
  5500,
  7700,
  3604,
  4893,
  9000
]

totals = [
  12000,
  23000,
  43000,
  9000,
  21400
]

item_adjustments = [
  899,
  500,
  1504,
  3400
]

for user_id <- 2..11 do
  # Store 1
  for x <- 0..9 do
    invoice = Invoices.create_invoice(user_id)
    {:ok, cart} = Carts.create_cart(user_id, 1, invoice.id)
    # add items to cart
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})

    {:ok, invoice} =
      Invoices.update_invoice(invoice, %{
        delivery_fee: Money.new(499),
        driver_tip: Money.new(Enum.random(driver_tips)),
        sales_tax: Money.new(599),
        subtotal: Money.new(Enum.random(subtotals)),
        total: Money.new(Enum.random(totals)),
        item_adjustment: Money.new(Enum.random(item_adjustments)),
        delivery_time: "1pm to 3pm on Today",
        pm_intent_id: "somePaymentMethodID",
        payment_method: "Ending with 4242",
        status: Enum.random(statuses),
        total_items: 5,
        recipient: "David",
        address_line_one: "777 S Vermont Ave",
        address_line_two: "apt 333",
        business_name: "",
        zipcode: "90032",
        city: "LA",
        state: "CA",
        instructions: "Call if main gate is locked",
        phone_number: "2135556666"
      })

    {:ok, cart} = Carts.update_cart(cart, %{status: :submitted, available_checkout: true})
  end
end
