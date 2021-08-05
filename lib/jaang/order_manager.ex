defmodule Jaang.OrderManager do
  alias Jaang.Checkout.{Carts, Checkout}

  @doc """
  Create an cart(order) and attach to the invoice
  """
  defdelegate create_cart(user_id, store_id, invoice_id), to: Carts
  defdelegate get_cart(order_id), to: Carts
  defdelegate get_cart(user_id, store_id), to: Carts
  defdelegate get_all_carts_or_create_new(user), to: Carts
  defdelegate get_all_carts(user_id), to: Carts
  defdelegate update_cart(order, attrs), to: Carts
  defdelegate add_to_cart(cart, cart_attrs), to: Carts
  defdelegate change_quantity_from_cart(cart, cart_attrs), to: Carts

  defdelegate add_note_or_replacement_item(cart, note, replacement_item_id, line_item_id),
    to: Carts

  @doc """
  This function is called whenever fetch carts(orders).
  I need to check current product price to update line_item
  because price could be changed due to sale.
  If product is on sale, show sale price
  if not show original price
  params: List of %Order{}
  """
  defdelegate refresh_product_price(carts), to: Carts

  @doc """
  This function places an order using currently saved
  invoice schema, default address, phone number, default payment method.
  """
  defdelegate place_an_order(user, delivery_time), to: Checkout
end
