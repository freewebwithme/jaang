defmodule JaangWeb.Resolvers.CartResolver do
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

  defp get_updated_carts(user_id) do
    carts = OrderManager.get_all_carts(user_id)
    total_items = OrderManager.count_total_item(carts)
    total_price = OrderManager.calculate_total_price(carts)
    {carts, total_items, total_price}
  end
end
