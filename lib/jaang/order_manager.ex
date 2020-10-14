defmodule Jaang.OrderManager do
  alias Jaang.Checkout

  defdelegate create_cart(user_id, store_id), to: Checkout
  defdelegate get_cart(user_id, store_id), to: Checkout
  defdelegate get_all_carts_or_create_new(user), to: Checkout
  defdelegate update_cart(order, attrs), to: Checkout
  defdelegate add_to_cart(cart, cart_attrs), to: Checkout
end
