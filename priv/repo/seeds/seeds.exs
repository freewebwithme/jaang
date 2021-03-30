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

alias Jaang.{Store, Category, Product, SearchManager}
alias Jaang.Category.{SubCategory, Categories}
alias Jaang.Store.Stores
alias Jaang.Category.Categories
alias Jaang.Product.{Products, MarketPrice}
alias Jaang.Repo
import Ecto.Query

# Application.ensure_all_started(:timex)

timezone = "America/Los_Angeles"

# Create a stores
IO.puts("Creating Store started")

{:ok, store1} =
  Stores.create_store(%{
    name: "Costco",
    store_logo: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/store-logos/costco.png",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm",
    address: "777 Wilshire Blvd Los Angeles, CA 90032",
    phone_number: "2134445555"
  })

{:ok, store2} =
  Stores.create_store(%{
    name: "Gelson",
    store_logo: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/store-logos/gelson.png",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm",
    address: "555 Vermont Ave Los Angeles, CA 90054",
    phone_number: "2139994444"
  })

{:ok, store3} =
  Stores.create_store(%{
    name: "Smart & Final",
    store_logo:
      "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/store-logos/smartfinal.png",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm",
    address: "3256 Olympic Blvd Los Angeles, CA 90010",
    phone_number: "2139994444"
  })

IO.puts("Store Creation completed")

IO.puts("Create categories....")

# Create categories
{:ok, produce} =
  Categories.create_category(%{
    name: "Produce",
    description: "farm-produced crops, including fruits and vegetables"
  })

{:ok, meat_seafood} =
  Categories.create_category(%{
    name: "Meat & Seafood",
    description: "wild caught or farm-raised meat and seafood"
  })

{:ok, frozen} =
  Categories.create_category(%{
    name: "Frozen",
    description: "frozen dumpling, frozen pizza or hot dog etc"
  })

{:ok, snacks} =
  Categories.create_category(%{name: "Snacks", description: "cookies, biscuit or chips"})

{:ok, dairy_eggs} =
  Categories.create_category(%{name: "Dairy & Eggs", description: "milk, eggs and cheese"})

{:ok, deli} =
  Categories.create_category(%{
    name: "Deli",
    description: "a selection of fine, unusual, or foreign prepared foods"
  })

{:ok, beverages} =
  Categories.create_category(%{name: "Beverages", description: "soda, soft drinks and juice"})

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

IO.puts("Finished creating categories...")

IO.puts("Creating unit...")

# Create Unit
{:ok, lb} = Products.create_unit(%{name: "lb"})
{:ok, each} = Products.create_unit(%{name: "each"})
{:ok, pack} = Products.create_unit(%{name: "pack"})
{:ok, kg} = Products.create_unit(%{name: "kg"})
{:ok, ct} = Products.create_unit(%{name: "ct"})

IO.puts("Finished creating units...")

prices = [
  300,
  499,
  999,
  1099,
  599,
  1499,
  1599,
  2999,
  799,
  899
]

product_image_urls = [
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/Japchae-Potstickers.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/Live-Fluke.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/al-sae-woo.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/bacon.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/bcd-tofu.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/cabbage.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/coffee.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/coke.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/cold-noodle.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/cup-ban.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/curry.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/eggs.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/greek-yogurt.JPG",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/horizon-milk.JPG",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/ice-cream-2.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/ice-cream.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/lemonade.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/nutella.png",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/oj.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/onion-ring.jpeg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/pocky.png",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/pork-shoulder.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/red-cabbage.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/red-grape.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/salmon-filet.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/strawberry.png",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/tofu.jpg",
  "https://jaang-la.s3-us-west-1.amazonaws.com/product-images/yogurt.png"
]

units = [
  lb,
  each,
  pack,
  kg,
  ct
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

tags = [
  "egg, organic",
  "milk, probiotic",
  "beef, pasture raised",
  "orange, organic",
  "juice",
  "snacks",
  "candy",
  "kimchi",
  "tea",
  "organic",
  "ice cream"
]

recipe_tags = [
  "kimchi soup",
  "daenjang soup",
  "bulgogi",
  "korean bbq",
  "egg sandwich",
  "dduk Bok i",
  "udon soup",
  "korean pizza",
  "rice cake",
  "bibimbap"
]

product_names = [
  "kimchi soup",
  "daenjang soup",
  "bulgogi",
  "korean bbq",
  "egg sandwich",
  "dduk Bok i",
  "udon soup",
  "korean pizza",
  "rice cake",
  "bibimbap",
  "kimchi",
  "tofu",
  "beef",
  "mushroom",
  "onion",
  "yogurt",
  "dumpling",
  "seaweed",
  "ramen"
]

weight_baseds = [true, false]

# Create Products for store 1
IO.puts("Start to create PRODUCTS for Store 1")

for x <- 0..99 do
  store = store1
  category = Enum.random(categories)
  # get sub category
  sub_categories = Repo.all(from sc in SubCategory, where: sc.category_id == ^category.id)
  sub_category = Enum.random(sub_categories)
  unit = Enum.random(units)

  attrs = %{
    name: Enum.random(product_names),
    description:
      "This is nice product. #{x}.  Aut laboriosam illo adipisci quibusdam sapiente. Dignissimos mollitia ut eos. Voluptas omnis qui temporibus tempora quis officia. Porro dolorum architecto officia omnis quae maxime dolorem quas. Aut neque esse magnam sint temporibus delectus necessitatibus ratione.",
    ingredients:
      "Contains orange juice, Less than 1% of: Calcium phosphate and caclium lactate(calcium sources), Vitamin D3",
    directions:
      "Keep refrigerated. Shake well. Best if used within 7-10 days after opening. Do not use.",
    warnings: "Do no reuse.",
    published: true,
    unit_id: unit.id,
    unit_name: unit.name,
    store_name: store.name,
    store_id: store.id,
    category_name: category.name,
    category_id: category.id,
    sub_category_name: sub_category.name,
    sub_category_id: sub_category.id,
    tags: Enum.random(tags),
    recipe_tags: Enum.random(recipe_tags),
    weight_based: Enum.random(weight_baseds)
  }

  {:ok, product} = Products.create_product_for_seeds(attrs)

  product_images =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 1
    })

  product_images_2 =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 2
    })

  product_images_3 =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 3
    })

  attrs = %{
    start_date: Timex.to_datetime({{2019, 12, 24}, {0, 0, 0}}, timezone),
    end_date: Timex.to_datetime({{2039, 12, 12}, {0, 0, 0}}, timezone),
    on_sale: false,
    original_price: Money.new(Enum.random(prices), :USD),
    sale_price: Money.new(0, :USD)
  }

  MarketPrice.create_market_price_with_product_price(product.id, attrs)

  # Creating tags
end

IO.puts("Finished to create PRODUCTS for Store 1")

# Create Products for store 2
IO.puts("Start to create PRODUCTS for Store 2")

for x <- 0..99 do
  store = store2
  category = Enum.random(categories)
  # get sub category
  sub_categories = Repo.all(from sc in SubCategory, where: sc.category_id == ^category.id)
  sub_category = Enum.random(sub_categories)
  unit = Enum.random(units)

  attrs = %{
    name: Enum.random(product_names),
    description:
      "This is nice product. #{x}.  Aut laboriosam illo adipisci quibusdam sapiente. Dignissimos mollitia ut eos. Voluptas omnis qui temporibus tempora quis officia. Porro dolorum architecto officia omnis quae maxime dolorem quas. Aut neque esse magnam sint temporibus delectus necessitatibus ratione.",
    ingredients:
      "Contains orange juice, Less than 1% of: Calcium phosphate and caclium lactate(calcium sources), Vitamin D3",
    directions:
      "Keep refrigerated. Shake well. Best if used within 7-10 days after opening. Do not use.",
    warnings: "Do no reuse.",
    published: true,
    unit_id: unit.id,
    unit_name: unit.name,
    store_name: store.name,
    store_id: store.id,
    category_name: category.name,
    category_id: category.id,
    sub_category_name: sub_category.name,
    sub_category_id: sub_category.id,
    tags: Enum.random(tags),
    recipe_tags: Enum.random(recipe_tags),
    weight_based: Enum.random(weight_baseds)
  }

  {:ok, product} = Products.create_product_for_seeds(attrs)

  product_images =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 1
    })

  product_images_2 =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 2
    })

  product_images_3 =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 3
    })

  attrs = %{
    start_date: Timex.to_datetime({{2019, 12, 24}, {0, 0, 0}}, timezone),
    end_date: Timex.to_datetime({{2039, 12, 12}, {0, 0, 0}}, timezone),
    on_sale: false,
    original_price: Money.new(Enum.random(prices), :USD),
    sale_price: Money.new(0, :USD)
  }

  MarketPrice.create_market_price_with_product_price(product.id, attrs)
  # Creating tags
end

IO.puts("Finished to create PRODUCTS for Store 2")

# Create Products for store 3
IO.puts("Start to create PRODUCTS for Store 3")

for x <- 0..99 do
  store = store3
  category = Enum.random(categories)
  # get sub category
  sub_categories = Repo.all(from sc in SubCategory, where: sc.category_id == ^category.id)
  sub_category = Enum.random(sub_categories)
  unit = Enum.random(units)

  attrs = %{
    name: Enum.random(product_names),
    description:
      "This is nice product. #{x}.  Aut laboriosam illo adipisci quibusdam sapiente. Dignissimos mollitia ut eos. Voluptas omnis qui temporibus tempora quis officia. Porro dolorum architecto officia omnis quae maxime dolorem quas. Aut neque esse magnam sint temporibus delectus necessitatibus ratione.",
    ingredients:
      "Contains orange juice, Less than 1% of: Calcium phosphate and caclium lactate(calcium sources), Vitamin D3",
    directions:
      "Keep refrigerated. Shake well. Best if used within 7-10 days after opening. Do not use.",
    warnings: "Do no reuse.",
    published: true,
    unit_id: unit.id,
    unit_name: unit.name,
    store_name: store.name,
    store_id: store.id,
    category_name: category.name,
    category_id: category.id,
    sub_category_name: sub_category.name,
    sub_category_id: sub_category.id,
    tags: Enum.random(tags),
    recipe_tags: Enum.random(recipe_tags),
    weight_based: Enum.random(weight_baseds)
  }

  {:ok, product} = Products.create_product_for_seeds(attrs)

  product_images =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 1
    })

  product_images_2 =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 2
    })

  product_images_3 =
    Products.create_product_image(product, %{
      image_url: Enum.random(product_image_urls),
      order: 3
    })

  attrs = %{
    start_date: Timex.to_datetime({{2019, 12, 24}, {0, 0, 0}}, timezone),
    end_date: Timex.to_datetime({{2039, 12, 12}, {0, 0, 0}}, timezone),
    on_sale: false,
    original_price: Money.new(Enum.random(prices), :USD),
    sale_price: Money.new(0, :USD)
  }

  MarketPrice.create_market_price_with_product_price(product.id, attrs)
  # Creating tags
end

IO.puts("Finished to create PRODUCTS for Store 3")

IO.puts("Adding search_term....")
SearchManager.create_search_term(%{term: "kimchi", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "tofu", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "rice", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "ramen", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "mushroom", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "beef", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "rice cake", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "dumpling", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "seaweed", counter: 1, store_id: 1})
SearchManager.create_search_term(%{term: "noodles", counter: 1, store_id: 1})

SearchManager.create_search_term(%{term: "kimchi", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "tofu", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "rice", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "ramen", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "mushroom", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "beef", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "rice cake", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "dumpling", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "seaweed", counter: 1, store_id: 2})
SearchManager.create_search_term(%{term: "noodles", counter: 1, store_id: 2})

SearchManager.create_search_term(%{term: "kimchi", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "tofu", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "rice", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "ramen", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "mushroom", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "beef", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "rice cake", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "dumpling", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "seaweed", counter: 1, store_id: 3})
SearchManager.create_search_term(%{term: "noodles", counter: 1, store_id: 3})
IO.puts("Finished adding search_term.")

IO.puts("Finished seeds.exs")
