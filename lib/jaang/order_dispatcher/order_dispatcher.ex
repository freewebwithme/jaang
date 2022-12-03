defmodule Jaang.OrderDispatcher do
  alias Jaang.Admin.ShopperManager

  @doc """
  Assign a shopper to invoice(order)
  set shopper id to invoice.shopper_id field
  """
  def assign_shopper_to_invoice(invoice) do
    # Check if order(invoice) has multiple store order
    case has_multiple_store_orders?(invoice) do
      true ->
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

  def find_available_shopper(store_id) do
    ShopperManager.get_best_available_shopper(store_id)
  end
end
