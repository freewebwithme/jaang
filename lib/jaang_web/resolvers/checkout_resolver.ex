defmodule JaangWeb.Resolvers.CheckoutResolver do
  alias Jaang.{AccountManager, OrderManager, InvoiceManager}
  alias Jaang.Checkout.Calculate
  alias Jaang.Invoice.TotalAmount

  @doc """
  Calculate final total amount
  and Update invoice total amount and invoice schema
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

    # %{store_name: "", total: %Money{}}
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

    sub_totals_amount = Calculate.calculate_subtotals(carts)

    # Get an invoice schema
    invoice = InvoiceManager.get_invoice_in_cart(user.id)
    # Update an invoice schema
    InvoiceManager.update_invoice(invoice, %{
      delivery_fee: delivery_fee,
      driver_tip: tip,
      sales_tax: tax,
      service_fee: service_fee,
      subtotal: sub_totals_amount,
      total: final_total_amount
    })

    total_amount = %TotalAmount{
      driver_tip: tip,
      sub_totals: sub_totals,
      delivery_fee: delivery_fee,
      service_fee: service_fee,
      sales_tax: tax,
      item_adjustments: item_adjustments,
      total: final_total_amount
    }

    {:ok, total_amount}
  end

  def place_an_order(_, %{token: token}, _) do
    user = AccountManager.get_user_by_session_token(token)

    case OrderManager.place_an_order(user) do
      {:ok, invoice} ->
        {:ok, invoice}

      {:error, message} ->
        {:error, nil}
    end
  end
end
