alias Jaang.Product.ProductPrice

start_date = Timex.to_datetime({{2021, 1, 5}, {14, 0, 0}}, "America/Los_Angeles")
end_date = Timex.to_datetime({{2021, 1, 5}, {19, 0, 0}}, "America/Los_Angeles")

# Create sales product price
for x <- 0..99 do
  product_id = Enum.random(0..8999)
  product_price = ProductPrice.get_product_price(product_id)

  # Calculate sale price
  sale_price = Money.subtract(product_price.original_price, Money.new(200))

  ProductPrice.create_on_sale_price(product_id, sale_price, start_date, end_date)
end
