defmodule JaangWeb.Resolvers.CartResolver do
  @moduledoc """
  This resolver is not being used
  Instead I use CartChannel
  """
  alias Jaang.OrderManager

  def get_all_carts(_, %{user_id: user_id}, _) do
    {carts, total_items, total_price} = get_updated_carts(user_id)
    {:ok, %{orders: carts, total_items: total_items, total_price: total_price}}
  end

  def add_to_cart(
        _,
        %{user_id: user_id, product_id: product_id, store_id: store_id, quantity: quantity},
        _
      ) do
    user_id = String.to_integer(user_id)
    # get a cart for store
    case OrderManager.get_cart(user_id, store_id) do
      nil ->
        # There is no cart for store.  Create initial carts
        {:ok, cart} = OrderManager.create_cart(user_id, store_id)
        # Add item to cart
        OrderManager.add_to_cart(cart, %{product_id: product_id, quantity: quantity})

        # Get updated carts
        {carts, total_items, total_price} = get_updated_carts(user_id)

        {:ok, %{orders: carts, total_items: total_items, total_price: total_price}}

      cart ->
        # Add item to cart
        OrderManager.add_to_cart(cart, %{product_id: product_id, quantity: quantity})

        # Get updated carts
        {carts, total_items, total_price} = get_updated_carts(user_id)

        {:ok, %{orders: carts, total_items: total_items, total_price: total_price}}
    end
  end

  def update_cart(
        _,
        %{user_id: user_id, product_id: _product_id, store_id: store_id, quantity: _quantity} =
          attrs,
        _
      ) do
    user_id = String.to_integer(user_id)
    cart = OrderManager.get_cart(user_id, store_id)
    OrderManager.change_quantity_from_cart(cart, attrs)

    # Get updated carts
    {carts, total_items, total_price} = get_updated_carts(user_id)

    {:ok, %{orders: carts, total_items: total_items, total_price: total_price}}
  end

  def get_updated_carts(user_id) do
    carts = OrderManager.get_all_carts(user_id)

    # Extract line items and sort by inserted at
    sorted_carts =
      Enum.map(carts, fn %{line_items: line_items} = cart ->
        line_items = Enum.sort(line_items, &(&1.inserted_at <= &2.inserted_at))
        Map.put(cart, :line_items, line_items)
      end)

    total_items = OrderManager.count_total_item(sorted_carts)
    total_price = OrderManager.calculate_total_price(sorted_carts)
    {sorted_carts, total_items, total_price}
  end
end
