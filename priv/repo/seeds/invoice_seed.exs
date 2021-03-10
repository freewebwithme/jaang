alias Jaang.Checkout.Carts
alias Jaang.Checkout.Order
alias Jaang.Invoice.Invoices
alias Jaang.Store.DeliveryDateTimes

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

names = [
  "James",
  "David",
  "John",
  "Tim",
  "Peter",
  "Robert",
  "Young",
  "Kimberly"
]

available_hours = [
  "3 pm to 5 pm on Mon, Mar 8, 2021",
  "5 pm to 7 pm on Mon, Mar 8, 2021",
  "7 pm to 9 pm on Mon, Mar 8, 2021",
  "3 pm to 5 pm on Tue, Mar 9, 2021",
  "5 pm to 7 pm on Tue, Mar 9, 2021",
  "7 pm to 9 pm on Tue, Mar 9, 2021",
  "3 pm to 5 pm on Wed, Mar 10, 2021",
  "5 pm to 7 pm on Wed, Mar 10, 2021",
  "7 pm to 9 pm on Wed, Mar 10, 2021",
  "3 pm to 5 pm on Thu, Mar 11, 2021",
  "5 pm to 7 pm on Thu, Mar 11, 2021",
  "7 pm to 9 pm on Thu, Mar 11, 2021",
  "3 pm to 5 pm on Fri, Mar 12, 2021",
  "5 pm to 7 pm on Fri, Mar 12, 2021",
  "7 pm to 9 pm on Fri, Mar 12, 2021"
]

phone_numbers = [
  "2134445555",
  "2132224444",
  "3102346567",
  "2135492345",
  "2139073454"
]

for user_id <- 1..11 do
  # Store 1
  for x <- 0..9 do
    IO.puts("Creating for Store 1")
    invoice = Invoices.create_invoice(user_id)
    {:ok, cart} = Carts.create_cart(user_id, 1, invoice.id)
    # add items to cart
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(1..100), quantity: 1})
    delivery_time = Enum.random(available_hours)
    {delivery_order, delivery_date} = DeliveryDateTimes.parse_delivery_datetime(delivery_time)
    order_placed_at = DateTime.utc_now() |> DateTime.truncate(:second)
    status = Enum.random(statuses)

    {:ok, invoice} =
      Invoices.update_invoice(invoice, %{
        delivery_fee: Money.new(499),
        driver_tip: Money.new(Enum.random(driver_tips)),
        sales_tax: Money.new(599),
        subtotal: Money.new(Enum.random(subtotals)),
        total: Money.new(Enum.random(totals)),
        item_adjustment: Money.new(Enum.random(item_adjustments)),
        delivery_time: delivery_time,
        delivery_date: delivery_date,
        delivery_order: delivery_order,
        invoice_placed_at: order_placed_at,
        pm_intent_id: "somePaymentMethodID",
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

  for x <- 0..9 do
    IO.puts("Creating for Store 2")
    invoice = Invoices.create_invoice(user_id)
    {:ok, cart} = Carts.create_cart(user_id, 2, invoice.id)
    # add items to cart
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(150..200), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(150..200), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(150..200), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(150..200), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(150..200), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(150..200), quantity: 1})
    delivery_time = Enum.random(available_hours)
    {delivery_order, delivery_date} = DeliveryDateTimes.parse_delivery_datetime(delivery_time)

    {:ok, invoice} =
      Invoices.update_invoice(invoice, %{
        delivery_fee: Money.new(499),
        driver_tip: Money.new(Enum.random(driver_tips)),
        sales_tax: Money.new(599),
        subtotal: Money.new(Enum.random(subtotals)),
        total: Money.new(Enum.random(totals)),
        item_adjustment: Money.new(Enum.random(item_adjustments)),
        delivery_time: delivery_time,
        delivery_date: delivery_date,
        delivery_order: delivery_order,
        order_placed_at: DateTime.utc_now() |> DateTime.truncate(:second),
        pm_intent_id: "somePaymentMethodID",
        payment_method: "Ending with 4242",
        status: Enum.random(statuses),
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

    {:ok, cart} = Carts.update_cart(cart, %{status: :submitted, available_checkout: true})
  end

  for x <- 0..9 do
    IO.puts("Creating for Store 3")
    invoice = Invoices.create_invoice(user_id)
    {:ok, cart} = Carts.create_cart(user_id, 3, invoice.id)
    # add items to cart
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(201..300), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(201..300), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(201..300), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(201..300), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(201..300), quantity: 1})
    {:ok, cart} = Carts.add_to_cart(cart, %{product_id: Enum.random(201..300), quantity: 1})
    delivery_time = Enum.random(available_hours)
    {delivery_order, delivery_date} = DeliveryDateTimes.parse_delivery_datetime(delivery_time)

    {:ok, invoice} =
      Invoices.update_invoice(invoice, %{
        delivery_fee: Money.new(499),
        driver_tip: Money.new(Enum.random(driver_tips)),
        sales_tax: Money.new(599),
        subtotal: Money.new(Enum.random(subtotals)),
        total: Money.new(Enum.random(totals)),
        item_adjustment: Money.new(Enum.random(item_adjustments)),
        delivery_time: delivery_time,
        delivery_date: delivery_date,
        delivery_order: delivery_order,
        order_placed_at: DateTime.utc_now() |> DateTime.truncate(:second),
        pm_intent_id: "somePaymentMethodID",
        payment_method: "Ending with 4242",
        status: Enum.random(statuses),
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

    {:ok, cart} = Carts.update_cart(cart, %{status: :submitted, available_checkout: true})
  end
end
