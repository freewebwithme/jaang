# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Jaang.Repo.insert!(%Jaang.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Jaang.{Store, Category, Product}
alias Jaang.Category.{SubCategory, Categories}
alias Jaang.Store.Stores
alias Jaang.Category.Categories
alias Jaang.Product.Products
alias Jaang.Repo

# Create a stores
{:ok, store1} =
  Stores.create_store(%{
    name: "LA Mart",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm",
    address: "777 Wilshire Blvd Los Angeles, CA 90032",
    phone_number: "2134445555"
  })

{:ok, store2} =
  Stores.create_store(%{
    name: "California Mart",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm",
    address: "555 Vermont Ave Los Angeles, CA 90054",
    phone_number: "2139994444"
  })

{:ok, store3} =
  Stores.create_store(%{
    name: "HanIn Mart",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm",
    address: "3256 Olympic Blvd Los Angeles, CA 90010",
    phone_number: "2139994444"
  })

# Create categories
{:ok, produce} = Categories.create_category(%{name: "Produce"})
{:ok, meat_seafood} = Categories.create_category(%{name: "Meat & Seafood"})
{:ok, frozen} = Categories.create_category(%{name: "Frozen"})
{:ok, snacks} = Categories.create_category(%{name: "Snacks"})
{:ok, dairy_eggs} = Categories.create_category(%{name: "Dairy & Eggs"})
{:ok, deli} = Categories.create_category(%{name: "Deli"})
{:ok, beverages} = Categories.create_category(%{name: "Beverages"})

# Create sub-categories
# Produce
{:ok, fresh_veg} = Categories.create_subcategory(produce, %{name: "Fresh Vegetables"})
{:ok, fresh_fruits} = Categories.create_subcategory(produce, %{name: "Fresh Fruits"})

# Meat & Seafood
{:ok, packaged_pork} = Categories.create_subcategory(meat_seafood, %{name: "Packaged Pork"})
{:ok, packaged_beef} = Categories.create_subcategory(meat_seafood, %{name: "Packaged Beef"})

# Frozen
{:ok, frozen_dump} = Categories.create_subcategory(frozen, %{name: "Frozen Dumplings"})
{:ok, ice_cream} = Categories.create_subcategory(frozen, %{name: "Ice Cream"})

# Snacks
{:ok, cookies_cakes} = Categories.create_subcategory(snacks, %{name: "Cookies, Cakes & Pies"})
{:ok, candy_choco} = Categories.create_subcategory(snacks, %{name: "Candy & Chocolate"})

# Dairy and Eggs
{:ok, eggs} = Categories.create_subcategory(dairy_eggs, %{name: "Eggs"})
{:ok, milk} = Categories.create_subcategory(dairy_eggs, %{name: "Milks"})

# Deli
{:ok, prepared_meals} = Categories.create_subcategory(deli, %{name: "Prepared Meals"})
{:ok, lunch_meat} = Categories.create_subcategory(deli, %{name: "Lunch Meat"})

# Beverages
{:ok, tea} = Categories.create_subcategory(beverages, %{name: "Tea"})
{:ok, juice} = Categories.create_subcategory(beverages, %{name: "Juice & Nectars"})

# Create Unit
{:ok, lb} = Products.create_unit(%{name: "lb"})
{:ok, each} = Products.create_unit(%{name: "each"})
{:ok, pack} = Products.create_unit(%{name: "pack"})

prices = [
  300,
  499,
  999,
  1099,
  599,
  1499
]

product_image_urls = [
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Live-Fluke.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/al-sae-woo.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/bacon.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/bcd-tofu.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/cabbage.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/coffee.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/coke.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/cold-noodle.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/cup-ban.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/curry.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/eggs.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/greek-yogurt.JPG",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/horizon-milk.JPG",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/ice-cream-2.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/ice-cream.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/lemonade.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/nutella.png",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/oj.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/onion-ring.jpeg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/pocky.png",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/pork-shoulder.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/red-cabbage.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/red-grape.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/salmon-filet.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/strawberry.png",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/tofu.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/yogurt.png"
]

units = [
  lb,
  each,
  pack
]

stores = [
  store1,
  store2,
  store3
]

categories = [
  produce,
  meat_seafood,
  deli,
  frozen,
  snacks,
  dairy_eggs,
  beverages
]

sub_categories = [
  fresh_veg,
  fresh_fruits,
  packaged_pork,
  packaged_beef,
  frozen_dump,
  ice_cream,
  cookies_cakes,
  candy_choco,
  eggs,
  milk,
  prepared_meals,
  lunch_meat,
  tea,
  juice
]

# Create Products
for x <- 0..99 do
  store = Enum.random(stores)
  category = Enum.random(categories)
  sub_category = Enum.random(sub_categories)
  unit = Enum.random(units)

  attrs = %{
    name: "Product-#{x}",
    description: "This is nice product #{x}",
    regular_price: Enum.random(prices),
    published: true,
    unit_id: unit.id,
    unit_name: unit.name,
    store_name: store.name,
    store_id: store.id,
    category_name: category.name,
    category_id: sub_category.category_id,
    sub_category_name: sub_category.name,
    sub_category_id: sub_category.id
  }

  {:ok, product} = Products.create_product(attrs)

  product_images =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      default: true
    })
end
