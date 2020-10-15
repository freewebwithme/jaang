defmodule JaangWeb.Resolvers.CartResolver do
  alias Jaang.OrderManager

  def get_all_carts(_, %{user_id: user_id}, _) do
    carts = OrderManager.get_all_carts(user_id)
    total_items = OrderManager.count_total_item(carts)
    total_price = OrderManager.calculate_total_price(carts)
    {:ok, %{orders: carts, total_items: total_items, total_price: total_price}}
  end
end
