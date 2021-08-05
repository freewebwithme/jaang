defmodule JaangWeb.Resolvers.CheckoutResolver do
  alias Jaang.{AccountManager, OrderManager, InvoiceManager}
  alias Jaang.Checkout.Calculate
  alias Jaang.Invoice.{StoreTotalAmount, TotalAmount}

  @doc """
  Calculate final total amount
  and Update invoice total amount and invoice schema
  """

  def calculate_total_for_store(_, %{token: token, order_id: order_id, tip: tip}, _) do
    user = AccountManager.get_user_by_session_token(token)
    order = OrderManager.get_cart(order_id)

    tip =
      if(tip == "") do
        String.to_integer("0")
        |> Money.new()
      else
        String.to_integer(tip) |> Money.new()
      end

    # Check if order is belong to the user
    case order.user_id == user.id do
      true ->
        tax = Calculate.calculate_sales_tax_for_store(order, :not_ready)
        item_adjustment = Calculate.calculate_item_adjustments(order.total)
        delivery_fee = Calculate.get_delivery_fee()

        grand_total =
          Calculate.calculate_grand_total_for_store(
            order.total,
            tax,
            item_adjustment,
            tip,
            delivery_fee
          )

        # update order(cart)
        OrderManager.update_cart(order, %{
          delivery_fee: delivery_fee,
          delivery_tip: tip,
          sales_tax: tax,
          item_adjustment: item_adjustment,
          grand_total: grand_total
        })

        # ! and update Invoice also?

        ## Get an invoice schema
        # invoice = InvoiceManager.get_invoice_in_cart(user.id)
        ## Update an invoice schema
        # InvoiceManager.update_invoice(invoice, %{
        #  delivery_fee: delivery_fee,
        #  driver_tip: tip,
        #  sales_tax: tax,
        #  subtotal: sub_totals_amount,
        #  total: final_total_amount,
        #  item_adjustment: item_adjustments,
        #  delivery_time: delivery_time
        # })
        carts = OrderManager.get_all_carts(user.id)
        grand_final_total = Calculate.calculate_grand_total_price(carts)

        store_total_amount = %StoreTotalAmount{
          driver_tip: tip,
          delivery_fee: delivery_fee,
          sales_tax: tax,
          item_adjustment: item_adjustment,
          total: order.total,
          grand_total: grand_total,
          grand_final_total: grand_final_total
        }

        IO.puts("Printing grand final total")
        IO.inspect(store_total_amount)

        {:ok, store_total_amount}

      false ->
        {:error, "Failed to process your cart information"}
    end
  end
end
