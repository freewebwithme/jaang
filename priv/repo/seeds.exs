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
    available_hours: "11am - 7pm"
  })

{:ok, store2} =
  Stores.create_store(%{
    name: "California Mart",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm"
  })

{:ok, store3} =
  Stores.create_store(%{
    name: "HanIn Mart",
    description: "Best market available in Los Angeles",
    price_info: "Online prices may be higher than store's price",
    available_hours: "11am - 7pm"
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
{:ok, packaged_beef} = Categories.create_subcategory(meat_seafood, %{name: "Packaged Bee"})

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
