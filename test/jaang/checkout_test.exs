defmodule Jaang.CheckoutTest do
  use Jaang.DataCase, async: true
  alias Jaang.{AccountManager, StoreManager, ProductManager, OrderManager, InvoiceManager}

  setup do
    attrs = %{
      email: "test@example.com",
      password: "secretsecret",
      password_confirmation: "secretsecret",
      profile: %{
        first_name: "Taehwan",
        last_name: "Kim",
        phone: "2135055819"
      }
    }

    {:ok, user} = AccountManager.create_user_with_profile(attrs)

    {:ok, store_1} =
      StoreManager.create_store(%{
        name: "Store1",
        description: "description",
        price_info: "price info",
        available_hours: "available hours"
      })

    {:ok, store_2} =
      StoreManager.create_store(%{
        name: "Store2",
        description: "description",
        price_info: "price info",
        available_hours: "available hours"
      })

    {:ok, product_1} =
      ProductManager.create_product(%{
        name: "Product1",
        description: "Product1 description",
        regular_price: 300,
        sale_price: 200,
        vendor: "Nongshim",
        published: true,
        barcode: "123",
        store_id: store_1.id,
        unit_name: "lb",
        category_name: "Produce",
        sub_category_name: "Vegetable"
      })

    ProductManager.create_product_image(product_1, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    {:ok, product_2} =
      ProductManager.create_product(%{
        name: "Product2",
        description: "Product2 description",
        regular_price: 300,
        sale_price: 200,
        vendor: "Nongshim",
        published: true,
        barcode: "123",
        store_id: store_1.id,
        unit_name: "lb",
        category_name: "Drink",
        sub_category_name: "Soda"
      })

    ProductManager.create_product_image(product_2, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    {:ok, product_3} =
      ProductManager.create_product(%{
        name: "Product3",
        description: "Product3 description",
        regular_price: 1000,
        sale_price: 900,
        vendor: "Bingrae",
        published: true,
        barcode: "1234534",
        store_id: store_2.id,
        unit_name: "pack",
        category_name: "Dairy",
        sub_category_name: "Egg"
      })

    ProductManager.create_product_image(product_3, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    {:ok, product_4} =
      ProductManager.create_product(%{
        name: "Product4",
        description: "Product4 description",
        regular_price: 1000,
        sale_price: 900,
        vendor: "Bingrae",
        published: true,
        barcode: "1234534",
        store_id: store_2.id,
        unit_name: "pack",
        category_name: "Dairy",
        sub_category_name: "Milk"
      })

    ProductManager.create_product_image(product_4, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    # Create an invoice
    invoice = InvoiceManager.get_or_create_invoice(user.id)

    {:ok,
     %{
       user: user,
       store_1: store_1,
       store_2: store_2,
       product_1: product_1,
       product_2: product_2,
       product_3: product_3,
       product_4: product_4,
       invoice: invoice
     }}
  end

  test "create initial cart for each store", context do
    user = context[:user]
    store_1 = context[:store_1]
    store_2 = context[:store_2]
    invoice = context[:invoice]

    {:ok, cart_1} = OrderManager.create_cart(user.id, store_1.id, invoice.id)
    {:ok, cart_2} = OrderManager.create_cart(user.id, store_2.id, invoice.id)

    assert cart_1.status == :cart
    assert cart_1.store_id == store_1.id

    assert cart_2.status == :cart
    assert cart_2.store_id == store_2.id
  end

  test "get_cart", context do
    user = context[:user]
    store_1 = context[:store_1]
    store_2 = context[:store_2]
    invoice = context[:invoice]

    {:ok, cart_1} = OrderManager.create_cart(user.id, store_1.id, invoice.id)
    {:ok, cart_2} = OrderManager.create_cart(user.id, store_2.id, invoice.id)

    saved_cart_1 = OrderManager.get_cart(user.id, store_1.id)
    saved_cart_2 = OrderManager.get_cart(user.id, store_2.id)

    all_carts = OrderManager.get_all_carts(user.id)

    assert Enum.count(all_carts) == 2
    assert cart_1.id == saved_cart_1.id
    assert cart_2.id == saved_cart_2.id
  end

  test "add to cart", context do
    user = context[:user]
    store_1 = context[:store_1]
    product_1 = context[:product_1]
    product_2 = context[:product_2]
    invoice = context[:invoice]

    {:ok, cart} = OrderManager.create_cart(user.id, store_1.id, invoice.id)

    {:ok, new_cart} =
      OrderManager.add_to_cart(cart, %{product_id: Integer.to_string(product_1.id), quantity: 1})

    # Same cart?
    assert cart.id == new_cart.id

    # has single item?
    assert Enum.count(new_cart.line_items) == 1

    # Add 1 more item
    {:ok, new_cart2} =
      OrderManager.add_to_cart(new_cart, %{
        product_id: Integer.to_string(product_2.id),
        quantity: 1
      })

    # has 2 items?
    assert Enum.count(new_cart2.line_items) == 2
  end

  test "add same product to the cart increase quantity and total", context do
    user = context[:user]
    store_1 = context[:store_1]
    product_1 = context[:product_1]
    product_2 = context[:product_2]
    invoice = context[:invoice]

    {:ok, cart} = OrderManager.create_cart(user.id, store_1.id, invoice.id)

    {:ok, new_cart} =
      OrderManager.add_to_cart(cart, %{product_id: Integer.to_string(product_1.id), quantity: 1})

    {:ok, new_cart2} =
      OrderManager.add_to_cart(new_cart, %{
        product_id: Integer.to_string(product_1.id),
        quantity: 1
      })

    assert Enum.count(new_cart2.line_items) == 1

    [line_item] = Enum.take(new_cart2.line_items, 1)

    assert line_item.quantity == 2
    assert line_item.price.amount == product_1.regular_price.amount
    assert line_item.total.amount == product_1.regular_price.amount * 2
  end
end
