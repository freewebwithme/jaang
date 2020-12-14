defmodule Jaang.OrderManager do
  alias Jaang.Checkout.Carts

  @doc """
  Create an cart(order) and attach to the invoice
  """
  defdelegate create_cart(user_id, store_id, invoice_id), to: Carts
  defdelegate get_cart(user_id, store_id), to: Carts
  defdelegate get_all_carts_or_create_new(user), to: Carts
  defdelegate get_all_carts(user_id), to: Carts
  defdelegate update_cart(order, attrs), to: Carts
  defdelegate add_to_cart(cart, cart_attrs), to: Carts
  defdelegate change_quantity_from_cart(cart, cart_attrs), to: Carts

  defdelegate count_total_item(carts), to: Carts
  defdelegate calculate_total_price(carts), to: Carts
end
