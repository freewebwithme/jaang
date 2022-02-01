defmodule Jaang.ProductsTest do
  use Jaang.DataCase, async: true

  alias Jaang.{StoreManager, ProductManager}
  alias Jaang.Product
  alias Jaang.Product.{MarketPrice, ProductPrice, Products}

  setup do
    {:ok, store} = StoreManager.create_store(%{name: "Store1"})
    {:ok, store_2} = StoreManager.create_store(%{name: "Store2"})
    {:ok, store_3} = StoreManager.create_store(%{name: "Store3"})
    {:ok, category} = StoreManager.create_category(%{name: "Category1"})
    {:ok, category_2} = StoreManager.create_category(%{name: "Category2"})
    {:ok, category_3} = StoreManager.create_category(%{name: "Category3"})

    {:ok, sub_category} = StoreManager.create_subcategory(category, %{name: "SubCategory1"})
    {:ok, sub_category_2} = StoreManager.create_subcategory(category, %{name: "SubCategory2"})
    {:ok, sub_category_3} = StoreManager.create_subcategory(category, %{name: "SubCategory3"})

    attrs = %{
      name: "Product1",
      description: "Product1 description",
      vendor: "Nongshim",
      published: true,
      weight_based: true,
      barcode: "123",
      store_id: store.id,
      category_id: category.id,
      sub_category_id: sub_category.id,
      original_price: "5.99"
    }

    {:ok,
     %{
       product_attrs: attrs,
       store: store,
       store_2: store_2,
       store_3: store_3,
       category: category,
       category_2: category_2,
       category_3: category_3,
       sub_category: sub_category,
       sub_category_2: sub_category_2,
       sub_category_3: sub_category_3
     }}
  end

  test "create product with association correctly?", context do
    attrs = context[:product_attrs]
    store = context[:store]
    category = context[:category]
    sub_category = context[:sub_category]

    product = ProductManager.create_product(attrs)

    {:ok, _product_image1} =
      ProductManager.create_product_image(product, %{
        image_url: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/yogurt.png",
        order: 1
      })

    {:ok, _product_image2} =
      ProductManager.create_product_image(product, %{
        image_url: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/tofu.jpg",
        order: 2
      })

    product = ProductManager.get_product(product.id)

    assert product.name == "Product1"
    assert product.description == "Product1 description"
    assert product.vendor == "Nongshim"
    assert product.weight_based == true
    assert product.published == true
    assert product.barcode == "123"
    # Check association
    assert product.store_id == store.id
    assert product.category_id == category.id
    assert product.sub_category_id == sub_category.id

    # Get product with preload product images
    query = from p in Product, where: p.id == ^product.id
    product = Repo.one(query) |> Repo.preload([:product_images, :product_prices, :market_prices])

    product_images = product.product_images
    assert is_list(product_images)
    assert Enum.count(product_images) == 2

    # Check product_prices and market_prices
    [product_prices] = product.product_prices
    [market_prices] = product.market_prices

    assert market_prices.original_price == Money.new(599, :USD)
    assert product_prices.product_id == product.id
    customer_price = MarketPrice.calculate_price(market_prices.original_price)
    assert product_prices.original_price == customer_price
  end

  test "create unit correctly?" do
    {:ok, unit} = ProductManager.create_unit(%{name: "lb"})
    assert unit.name == "lb"
  end

  test "update product correctly?", context do
    attrs = context[:product_attrs]

    product = ProductManager.create_product(attrs)

    assert product.name == "Product1"

    # update product
    {:ok, updated_product} = ProductManager.update_product(product, %{name: "Updated Product1"})

    assert product.id == updated_product.id
    assert updated_product.name == "Updated Product1"
  end

  test "get product correctly?", context do
    attrs = context[:product_attrs]

    product = ProductManager.create_product(attrs)

    {:ok, _product_image1} =
      ProductManager.create_product_image(product, %{
        image_url: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/yogurt.png",
        order: 1
      })

    {:ok, _product_image2} =
      ProductManager.create_product_image(product, %{
        image_url: "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/tofu.jpg",
        order: 2
      })

    retrieved_product = ProductManager.get_product(product.id)

    assert product.id == retrieved_product.id
  end

  test "get sales products correctly?", context do
    store = context[:store]
    store_2 = context[:store_2]
    store_3 = context[:store_3]

    category = context[:category]
    category_2 = context[:category_2]
    category_3 = context[:category_3]

    sub_category = context[:sub_category]
    sub_category_2 = context[:sub_category_2]
    sub_category_3 = context[:sub_category_3]

    create_sales_products(
      store,
      store_2,
      store_3,
      category,
      category_2,
      category_3,
      sub_category,
      sub_category_2,
      sub_category_3
    )

    sales_products = ProductManager.get_sales_products(store.id, 1, 0)

    # check if there is only 3 sale item
    assert Enum.count(sales_products) == 1

    [sales_product] = sales_products
    # get product price
    [product_price] = sales_product.product_prices

    assert sales_product.store_id == store.id
    assert product_price.on_sale == true

    sales_products_2 = ProductManager.get_sales_products(store_2.id, 1, 0)

    # check if there is only 3 sale item
    assert Enum.count(sales_products_2) == 1

    [sales_product_2] = sales_products_2
    # get product price
    [product_price_2] = sales_product_2.product_prices

    assert sales_product_2.store_id == store_2.id
    assert product_price_2.on_sale == true
  end

  test "get_sales_products return only available products?", context do
    store = context[:store]
    store_2 = context[:store_2]
    store_3 = context[:store_3]

    category = context[:category]
    category_2 = context[:category_2]
    category_3 = context[:category_3]

    sub_category = context[:sub_category]
    sub_category_2 = context[:sub_category_2]
    sub_category_3 = context[:sub_category_3]
    # create sales products
    create_sales_products(
      store,
      store_2,
      store_3,
      category,
      category_2,
      category_3,
      sub_category,
      sub_category_2,
      sub_category_3
    )

    result =
      crate_sales_expired_products(
        store,
        category,
        sub_category
      )

    sales_products = ProductManager.get_sales_products(store.id, 5, 0)

    # store has 4 products, 3 sales products and 1 sale ends product
    assert Enum.count(sales_products) == 3
  end

  test "get related_products correctly?", context do
    attrs = context[:product_attrs]
    product_1_attrs = Map.merge(attrs, %{tags: "organic"})
    product_2_attrs = Map.merge(attrs, %{tags: "organic"})
    product_3_attrs = Map.merge(attrs, %{tags: "soda"})

    product_1 = ProductManager.create_product(product_1_attrs)
    product_2 = ProductManager.create_product(product_2_attrs)
    product_3 = ProductManager.create_product(product_3_attrs)

    related_products = ProductManager.get_related_products(product_1.id, 5)

    assert Enum.count(related_products) == 1
  end

  test "get oftenbought_products correctly?", context do
    attrs = context[:product_attrs]
    product_1_attrs = Map.merge(attrs, %{recipe_tags: "soup, miso"})
    product_2_attrs = Map.merge(attrs, %{recipe_tags: "soup"})
    product_3_attrs = Map.merge(attrs, %{recipe_tags: "miso"})

    product_1 = ProductManager.create_product(product_1_attrs)
    product_2 = ProductManager.create_product(product_2_attrs)
    product_3 = ProductManager.create_product(product_3_attrs)

    related_products = ProductManager.get_often_bought_with_products(product_1.id, 5)

    assert Enum.count(related_products) == 2
  end

  test "get_products_by_ids correctly?", context do
    # create products for 2 different stores
    store = context[:store]
    store_2 = context[:store_2]
    attrs = context[:product_attrs]
    product_1_attrs = Map.merge(attrs, %{store_id: store.id})
    product_2_attrs = Map.merge(attrs, %{store_id: store.id})
    product_3_attrs = Map.merge(attrs, %{store_id: store.id})

    product_4_attrs = Map.merge(attrs, %{store_id: store_2.id})

    product_1 = ProductManager.create_product(product_1_attrs)
    product_2 = ProductManager.create_product(product_2_attrs)
    product_3 = ProductManager.create_product(product_3_attrs)
    product_4 = ProductManager.create_product(product_4_attrs)

    product_ids = [product_1.id, product_2.id, product_3.id, product_4.id]

    products = Products.get_products_by_ids(product_ids, store.id)

    assert Enum.count(products) == 3

    store_2_products = Products.get_products_by_ids(product_ids, store_2.id)

    assert Enum.count(store_2_products) == 1
  end

  defp crate_sales_expired_products(
         store,
         category,
         sub_category
       ) do
    # create expired sales product
    attrs = %{
      name: "Product",
      description: "Product description",
      vendor: "Nongshim",
      published: true,
      weight_based: true,
      barcode: "123",
      store_id: store.id,
      category_id: category.id,
      sub_category_id: sub_category.id,
      original_price: "5.99"
    }

    product = ProductManager.create_product(attrs)
    product_price = ProductPrice.get_product_price(product.id)

    # Calculate sale price
    sale_price = Money.subtract(product_price.original_price, Money.new(200))

    start_date = Timex.to_datetime({{2022, 1, 30}, {12, 02, 0}}, "America/Los_Angeles")
    end_date = Timex.to_datetime({{2022, 1, 31}, {12, 15, 0}}, "America/Los_Angeles")

    MarketPrice.create_on_sale_price(product.id, sale_price, start_date, end_date)
  end

  defp create_sales_products(
         store,
         store_2,
         store_3,
         category,
         category_2,
         category_3,
         sub_category,
         sub_category_2,
         sub_category_3
       ) do
    for x <- 1..3 do
      attrs = %{
        name: "Product#{x}",
        description: "Product#{x} description",
        vendor: "Nongshim",
        published: true,
        weight_based: true,
        barcode: "123",
        store_id: store.id,
        category_id: category.id,
        sub_category_id: sub_category.id,
        original_price: "5.99"
      }

      product = ProductManager.create_product(attrs)
      product_price = ProductPrice.get_product_price(product.id)

      # Calculate sale price
      sale_price = Money.subtract(product_price.original_price, Money.new(200))

      start_date = Timex.to_datetime({{2022, 1, 31}, {12, 02, 0}}, "America/Los_Angeles")
      end_date = Timex.to_datetime({{2022, 3, 01}, {12, 15, 0}}, "America/Los_Angeles")

      MarketPrice.create_on_sale_price(product.id, sale_price, start_date, end_date)
    end

    for x <- 4..6 do
      attrs = %{
        name: "Product#{x}",
        description: "Product#{x} description",
        vendor: "Nongshim",
        published: true,
        weight_based: true,
        barcode: "123",
        store_id: store_2.id,
        category_id: category_2.id,
        sub_category_id: sub_category_2.id,
        original_price: "5.99"
      }

      product = ProductManager.create_product(attrs)
      product_price = ProductPrice.get_product_price(product.id)

      # Calculate sale price
      sale_price = Money.subtract(product_price.original_price, Money.new(200))

      start_date = Timex.to_datetime({{2022, 1, 31}, {12, 02, 0}}, "America/Los_Angeles")
      end_date = Timex.to_datetime({{2022, 3, 01}, {12, 15, 0}}, "America/Los_Angeles")

      MarketPrice.create_on_sale_price(product.id, sale_price, start_date, end_date)
    end

    for x <- 7..9 do
      attrs = %{
        name: "Product#{x}",
        description: "Product#{x} description",
        vendor: "Nongshim",
        published: true,
        weight_based: true,
        barcode: "123",
        store_id: store_3.id,
        category_id: category_3.id,
        sub_category_id: sub_category_3.id,
        original_price: "5.99"
      }

      product = ProductManager.create_product(attrs)
      product_price = ProductPrice.get_product_price(product.id)

      # Calculate sale price
      sale_price = Money.subtract(product_price.original_price, Money.new(200))

      start_date = Timex.to_datetime({{2022, 1, 31}, {12, 02, 0}}, "America/Los_Angeles")
      end_date = Timex.to_datetime({{2022, 3, 01}, {12, 15, 0}}, "America/Los_Angeles")

      MarketPrice.create_on_sale_price(product.id, sale_price, start_date, end_date)
    end
  end
end
