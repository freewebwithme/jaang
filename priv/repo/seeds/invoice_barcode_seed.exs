alias Jaang.Checkout.Carts
alias Jaang.Checkout.Order
alias Jaang.Invoice.Invoices
alias Jaang.Store.DeliveryDateTimes
alias Jaang.Checkout.Calculate
alias Jaang.{OrderManager, StripeManager, AccountManager}
alias Jaang.Repo

# Create order(cart)
# loop through each user
statuses = [
  :submitted
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

names = [
  "Taehwan",
  "Jihye",
  "Young Rang"
]

available_hours = [
  "3 pm to 5 pm on Tue, Apr 6, 2021",
  "5 pm to 7 pm on Tue, Apr 6, 2021",
  "7 pm to 9 pm on Tue, Apr 6, 2021",
  "3 pm to 5 pm on Wed, Apr 7, 2021",
  "5 pm to 7 pm on Wed, Apr 7, 2021",
  "7 pm to 9 pm on Wed, Apr 7, 2021",
  "3 pm to 5 pm on Thu, Apr 8, 2021",
  "5 pm to 7 pm on Thu, Apr 8, 2021",
  "7 pm to 9 pm on Thu, Apr 8, 2021",
  "3 pm to 5 pm on Fri, Apr 8, 2021",
  "5 pm to 7 pm on Fri, Apr 8, 2021",
  "7 pm to 9 pm on Fri, Apr 8, 2021",
  "3 pm to 5 pm on Mon, Apr 12, 2021",
  "5 pm to 7 pm on Mon, Apr 12, 2021",
  "7 pm to 9 pm on Mon, Apr 12, 2021",
  "3 pm to 5 pm on Tue, Apr 13, 2021",
  "5 pm to 7 pm on Tue, Apr 13, 2021",
  "7 pm to 9 pm on Tue, Apr 13, 2021",
  "3 pm to 5 pm on Wed, Apr 14, 2021",
  "5 pm to 7 pm on Wed, Apr 14, 2021",
  "7 pm to 9 pm on Wed, Apr 14, 2021",
  "3 pm to 5 pm on Thu, Apr 15, 2021",
  "5 pm to 7 pm on Thu, Apr 15, 2021",
  "7 pm to 9 pm on Thu, Apr 15, 2021",
  "3 pm to 5 pm on Fri, Apr 16, 2021",
  "5 pm to 7 pm on Fri, Apr 16, 2021",
  "7 pm to 9 pm on Fri, Apr 16, 2021"
]

phone_numbers = [
  "2134445555",
  "2132224444",
  "3102346567",
  "2135492345",
  "2139073454"
]

for user_id <- 31..40 do
  # Store 1
  for x <- 0..3 do
    IO.puts("Creating for Store 1")
    invoice = Invoices.create_invoice(user_id)
    {:ok, cart} = Carts.create_cart(user_id, 1, invoice.id)
    # add items to cart
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 307, quantity: 2})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 306, quantity: 2})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 305, quantity: 2})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 304, quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 303, quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 302, quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: 301, quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..299), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..299), quantity: 3})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..299), quantity: 3})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..299), quantity: 1})
    delivery_time = Enum.random(available_hours)
    {delivery_order, delivery_date} = DeliveryDateTimes.parse_delivery_datetime(delivery_time)
    order_placed_at = DateTime.utc_now() |> DateTime.truncate(:second)
    status = Enum.random(statuses)

    invoice = Jaang.Admin.Invoice.Invoices.get_invoice(invoice.id)

    # Calculate carts
    sales_tax = Calculate.calculate_sales_tax(invoice.orders)
    subtotal = Calculate.calculate_subtotals(invoice.orders)
    delivery_fee = Money.new(499)
    tip = Money.new(Enum.random(driver_tips))
    item_adjustment = Money.new(Enum.random(item_adjustments))

    total =
      Calculate.calculate_final_total(tip, subtotal, delivery_fee, sales_tax, item_adjustment)

    IO.puts("Working on for Stripe")
    # Create payment method
    {:ok, payment_method_id} =
      StripeManager.create_payment_method("4242424242424242", 9, 2025, "123")

    user = AccountManager.get_user(user_id)

    # attach payment method to user
    StripeManager.attach_to_customer(payment_method_id, user.stripe_id)
    # Set default payment method
    StripeManager.set_default_payment_method(user.stripe_id, payment_method_id)

    # Create payment intent
    {:ok, payment_intent} =
      StripeManager.create_payment_intent(total.amount, user.stripe_id, payment_method_id)

    IO.puts("Finished Stripe jobs")

    {:ok, invoice} =
      Invoices.update_invoice(invoice, %{
        delivery_fee: delivery_fee,
        driver_tip: tip,
        sales_tax: sales_tax,
        subtotal: subtotal,
        total: total,
        item_adjustment: item_adjustment,
        delivery_time: delivery_time,
        delivery_date: delivery_date,
        delivery_order: delivery_order,
        invoice_placed_at: order_placed_at,
        pm_intent_id: payment_intent.id,
        payment_method: "Ending with 4242",
        status: status,
        total_items: 5,
        recipient: Enum.random(names),
        address_line_one: "777 S Vermont Ave",
        address_line_two: "apt 333",
        business_name: "",
        zipcode: "90032",
        city: "LA",
        state: "CA",
        instructions: "Call if main gate is locked",
        phone_number: Enum.random(phone_numbers)
      })

    {:ok, cart} =
      Carts.update_cart(cart, %{
        status: status,
        available_checkout: true,
        order_placed_at: order_placed_at
      })
  end
end
