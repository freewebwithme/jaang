defmodule JaangWeb.Resolvers.CheckoutResolver do
  alias Jaang.{AccountManager, OrderManager}
  alias Jaang.Checkout.Calculate
  alias Jaang.Invoice.TotalAmount

  @doc """
  Calculate final total amount
  and Update invoice total amount
  """
  def calculate_total(_, %{tip: tip, token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)
    carts = OrderManager.get_all_carts(user.id)

    tip =
      if(tip == "") do
        String.to_integer("0")
        |> Money.new()
      else
        String.to_integer(tip) |> Money.new()
      end

    # Calculate total price to calculate service fee
    total = OrderManager.calculate_total_price(carts)
    service_fee = Calculate.calculate_service_fee(total)

    tax = Calculate.calculate_sales_tax(carts)
    delivery_fee = Calculate.calculate_delivery_fee()
    sub_totals = Calculate.get_sub_totals_for_order(carts)
    item_adjustments = Calculate.calculate_item_adjustments(total)

    final_total_amount =
      Calculate.calculate_final_total(
        tip,
        total,
        delivery_fee,
        service_fee,
        tax,
        item_adjustments
      )

    total_amount = %TotalAmount{
      driver_tip: tip,
      sub_totals: sub_totals,
      delivery_fee: delivery_fee,
      service_fee: service_fee,
      sales_tax: tax,
      item_adjustments: item_adjustments,
      total: final_total_amount
    }

    # Check if already created an invoice for this cart
    # if not create a new invoice and update total amount

    {:ok, total_amount}
  end
end
