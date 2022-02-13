defmodule Jaang.CheckoutTest do
  use Jaang.DataCase
  # , async: true
  alias Jaang.{AccountManager, StoreManager, ProductManager, OrderManager, InvoiceManager}

  setup do
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

    attrs = %{
      email: "test@example.com",
      password: "secretsecret",
      password_confirmation: "secretsecret",
      profile: %{
        first_name: "Taehwan",
        last_name: "Kim",
        phone: "2135055819",
        store_id: store_1.id
      }
    }

    {:ok, user} = AccountManager.create_user_with_profile(attrs)

    {:ok, category_1} = StoreManager.create_category(%{name: "Category 1"})
    {:ok, category_2} = StoreManager.create_category(%{name: "Category 2"})
    {:ok, category_3} = StoreManager.create_category(%{name: "Category 3"})

    {:ok, sub_category_1} =
      StoreManager.create_subcategory(category_1, %{name: "Category 1 - Subcategory 1"})

    {:ok, sub_category_2} =
      StoreManager.create_subcategory(category_2, %{name: "Category 2 - Subcategory 2"})

    {:ok, sub_category_3} =
      StoreManager.create_subcategory(category_3, %{name: "Category 3 - Subcategory 3"})

    product_1 =
      ProductManager.create_product(%{
        name: "Product1",
        description: "Product1 description",
        original_price: "12.99",
        vendor: "Nongshim",
        published: true,
        barcode: "123",
        store_id: store_1.id,
        unit_name: "lb",
        category_id: category_1.id,
        sub_category_id: sub_category_1.id,
        category_name: category_1.name,
        sub_category_name: sub_category_1.name
      })

    ProductManager.create_product_image(product_1, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    product_2 =
      ProductManager.create_product(%{
        name: "Product2",
        description: "Product2 description",
        original_price: "5.99",
        vendor: "Nongshim",
        published: true,
        barcode: "123",
        store_id: store_1.id,
        unit_name: "lb",
        category_id: category_1.id,
        sub_category_id: sub_category_1.id,
        category_name: category_1.name,
        sub_category_name: sub_category_1.name
      })

    ProductManager.create_product_image(product_2, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    product_3 =
      ProductManager.create_product(%{
        name: "Product3",
        description: "Product3 description",
        original_price: "8.99",
        vendor: "Bingrae",
        published: true,
        barcode: "1234534",
        store_id: store_2.id,
        unit_name: "pack",
        category_id: category_2.id,
        sub_category_id: sub_category_2.id,
        category_name: category_2.name,
        sub_category_name: sub_category_2.name
      })

    ProductManager.create_product_image(product_3, %{
      image_url:
        "https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/Japchae-Potstickers.jpg",
      order: 1
    })

    product_4 =
      ProductManager.create_product(%{
        name: "Product4",
        description: "Product4 description",
        original_price: "13.99",
        vendor: "Bingrae",
        published: true,
        barcode: "1234534",
        store_id: store_2.id,
        unit_name: "pack",
        category_id: category_3.id,
        sub_category_id: sub_category_3.id,
        category_name: category_3.name,
        sub_category_name: sub_category_3.name
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
       category_1: category_1,
       category_2: category_2,
       category_3: category_3,
       sub_category_1: sub_category_1,
       sub_category_2: sub_category_2,
       sub_category_3: sub_category_3,
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

  test "get_all_carts_or_create_new/1", context do
    user = context[:user]
    store_1 = context[:store_1]
    product_1 = context[:product_1]
    product_2 = context[:product_2]

    carts = OrderManager.get_all_carts_or_create_new(user)

    # test empty cart
    assert Enum.count(carts) == 1

    # get cart
    retrieved_cart = OrderManager.get_cart(user.id, user.profile.store_id)
    [cart] = carts

    # same cart?
    assert cart.id == retrieved_cart.id

    # check if no item in cart
    assert Enum.count(cart.line_items) == 0

    # add items from single store
    OrderManager.add_to_cart(cart, %{product_id: Integer.to_string(product_1.id), quantity: 1})

    carts = OrderManager.get_all_carts_or_create_new(user)
    [cart] = carts

    # must be a single item in a cart
    assert Enum.count(cart.line_items) == 1

    # correct product id?
    [line_item] = Enum.take(cart.line_items, 1)
    assert line_item.product_id == product_1.id
  end

  test "get_all_carts_or_create_new/1, add items from multiple store", context do
    user = context[:user]
    store_1 = context[:store_1]
    store_2 = context[:store_2]
    product_1 = context[:product_1]
    product_3 = context[:product_3]
    invoice = context[:invoice]

    # create cart for each store
    {:ok, store_1_cart} = OrderManager.create_cart(user.id, store_1.id, invoice.id)
    {:ok, store_2_cart} = OrderManager.create_cart(user.id, store_2.id, invoice.id)

    OrderManager.add_to_cart(store_1_cart, %{
      product_id: Integer.to_string(product_1.id),
      quantity: 1
    })

    OrderManager.add_to_cart(store_2_cart, %{
      product_id: Integer.to_string(product_3.id),
      quantity: 1
    })

    carts = OrderManager.get_all_carts_or_create_new(user)

    # Is there 2 orders(carts)?
    assert Enum.count(carts) == 2

    [store_1_cart] = Enum.filter(carts, &(&1.store_id == store_1.id))

    [line_item] = Enum.take(store_1_cart.line_items, 1)

    # Check if correct product is in cart
    assert line_item.product_id == product_1.id

    [store_2_cart] = Enum.filter(carts, &(&1.store_id == store_2.id))

    [line_item] = Enum.take(store_2_cart.line_items, 1)

    # Check if correct product is in cart
    assert line_item.product_id == product_3.id
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
    retrieved_prod = ProductManager.get_product(product_1.id)
    [product_price] = retrieved_prod.product_prices

    assert line_item.quantity == 2
    assert line_item.price.amount == product_price.original_price.amount
    assert line_item.total.amount == product_price.original_price.amount * 2
  end

  test "change_quantity_from_cart/2, increase product's quantity?", context do
    # need a cart with line_items
    # create a cart
    user = context[:user]
    store_1 = context[:store_1]
    product_1 = context[:product_1]
    product_2 = context[:product_2]
    invoice = context[:invoice]

    {:ok, cart} = OrderManager.create_cart(user.id, store_1.id, invoice.id)

    {:ok, new_cart} =
      OrderManager.add_to_cart(cart, %{product_id: Integer.to_string(product_1.id), quantity: 1})

    {:ok, new_cart2} =
      OrderManager.change_quantity_from_cart(new_cart, %{
        product_id: to_string(product_1.id),
        quantity: 2
      })

    # cart has only 1 item?
    assert Enum.count(new_cart2.line_items) == 1

    # product_1's quantity must be 2
    [line_item] = Enum.filter(new_cart2.line_items, &(&1.product_id == product_1.id))
    assert line_item.quantity == 2
  end

  test "change_quantity_from_cart/2, decrease product's quantity?", context do
    user = context[:user]
    store_1 = context[:store_1]
    product_1 = context[:product_1]
    product_2 = context[:product_2]
    invoice = context[:invoice]

    {:ok, cart} = OrderManager.create_cart(user.id, store_1.id, invoice.id)

    {:ok, new_cart} =
      OrderManager.add_to_cart(cart, %{product_id: Integer.to_string(product_1.id), quantity: 2})

    {:ok, new_cart2} =
      OrderManager.change_quantity_from_cart(new_cart, %{
        product_id: to_string(product_1.id),
        quantity: 1
      })

    # cart has only 1 item?
    assert Enum.count(new_cart2.line_items) == 1

    # product_1's quantity must be 1
    [line_item] = Enum.filter(new_cart2.line_items, &(&1.product_id == product_1.id))
    assert line_item.quantity == 1
  end

  test "change_quantity_from_cart/2, quantity == 0 removes line_item?", context do
    user = context[:user]
    store_1 = context[:store_1]
    product_1 = context[:product_1]
    product_2 = context[:product_2]
    invoice = context[:invoice]

    {:ok, cart} = OrderManager.create_cart(user.id, store_1.id, invoice.id)

    {:ok, new_cart} =
      OrderManager.add_to_cart(cart, %{product_id: Integer.to_string(product_1.id), quantity: 1})

    # If there is no more line_items left, function return %Order{} not {:ok, %Order{}}
    OrderManager.change_quantity_from_cart(new_cart, %{
      product_id: to_string(product_1.id),
      quantity: 0
    })

    # get cart again
    retrieved_cart = OrderManager.get_cart(user.id, store_1.id)

    # quantity == 0, removes line_item from cart
    assert retrieved_cart == nil
  end

  test "change_quantity_from_cart/2, find and update correct product?", context do
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
        product_id: Integer.to_string(product_2.id),
        quantity: 1
      })

    {:ok, new_cart3} =
      OrderManager.change_quantity_from_cart(new_cart2, %{
        product_id: Integer.to_string(product_1.id),
        quantity: 2
      })

    {:ok, new_cart4} =
      OrderManager.change_quantity_from_cart(new_cart3, %{
        product_id: Integer.to_string(product_2.id),
        quantity: 3
      })

    # product_1's quantity must be 2
    [line_item] = Enum.filter(new_cart4.line_items, &(&1.product_id == product_1.id))
    assert line_item.quantity == 2

    # product_2's quantity must be 3
    [line_item] = Enum.filter(new_cart4.line_items, &(&1.product_id == product_2.id))
    assert line_item.quantity == 3
  end
end
