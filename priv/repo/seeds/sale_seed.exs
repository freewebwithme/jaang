alias Jaang.Product.MarketPrice

start_date = Timex.to_datetime({{2021, 1, 25}, {12, 02, 0}}, "America/Los_Angeles")
end_date = Timex.to_datetime({{2021, 1, 30}, {12, 15, 0}}, "America/Los_Angeles")

# Create sales product price
for x <- 0..29 do
  product_id = Enum.random(0..299)
  product_price = ProductPrice.get_product_price(product_id)

  # Calculate sale price
  sale_price = Money.subtract(product_price.original_price, Money.new(200))

  MarketPrice.create_on_sale_price(product_id, sale_price, start_date, end_date)
end
