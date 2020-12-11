defmodule JaangWeb.Resolvers.CheckoutResolver do
  alias Jaang.{AccountManager, OrderManager}
  alias Jaang.Checkout.Calculate

  def calculate_total(_, %{tip: tip, token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)
    carts = OrderManager.get_all_carts(user.id)

    tip = String.to_integer(tip)
    tip = Money.new(tip)
    # Calculate total price to calculate service fee
    total = OrderManager.calculate_total_price(carts)
    service_fee = Calculate.calculate_service_fee(total)

    tax = Calculate.calculate_sales_tax(carts)
    delivery_fee = Calculate.calculate_delivery_fee()
    sub_totals = Calculate.get_sub_totals_for_order(carts)

    final_total_amount =
      Calculate.calculate_final_total(tip, total, delivery_fee, service_fee, tax)

    {:ok,
     %{
       driver_tip: tip,
       sub_totals: sub_totals,
       delivery_fee: delivery_fee,
       service_fee: service_fee,
       sales_tax: tax,
       total: final_total_amount
     }}
  end
end
