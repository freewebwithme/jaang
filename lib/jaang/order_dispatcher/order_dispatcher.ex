defmodule Jaang.OrderDispatcher do
  alias Jaang.Invoice

  @doc """
  Assign a shopper to invoice(order)
  set shopper id to invoice.shopper_id field
  """
  def assign_shopper_to_invoice(invoice) do
    # Check if order(invoice) has multiple store order
    case has_multiple_store_orders?(invoice) do
      true ->
        # assign it to shopper,
        nil

      _ ->
        nil
    end

    # Split order by store.

    # then send each order to shopper.
  end

  defp has_multiple_store_orders?(invoice) do
    if Enum.count(invoice.orders) > 1 do
      true
    else
      false
    end
  end

  # How can I find best available shoper?
  # conditions -
  # 1. shopper who is currently not fulfilling order
  # 2. shopper who has better feedback(review)
  # 3. shopper who has better time record for fulfilling order(faster shopping time)
  # 4.
  def find_available_shopper(store_id) do
    shoppers = ShopperManager.get_shoppers_by_store(store_id)
  end
end
