defmodule Jaang.Checkout.Calculate do
  @tax_rate 0.095
  @delivery_fee 500

  @doc """
  Calculate service fee
  params : type %Money{} = total_amount
  """
  def calculate_service_fee(total_amount) do
    Money.multiply(total_amount, 0.08)
  end

  @doc """
  Los Angeles city tax rate is 9.5%
  Exclude produce product from tax
  params: carts

  return: tax = Money{amount: tax, currency: :USD}
  """
  def calculate_sales_tax(carts) do
    # Get total of carts exclude produce product total
    # get all lineItems excluding Produce
    total_excluding_produce =
      Enum.flat_map(carts, & &1.line_items)
      |> Enum.filter(&(&1.category_name != "Produce"))
      |> Enum.reduce(Money.new(0), fn line_item, acc ->
        Money.add(line_item.total, acc)
      end)

    Money.multiply(total_excluding_produce, @tax_rate)
  end

  def calculate_delivery_fee() do
    Money.new(@delivery_fee)
  end

  @doc """
  params: List of %Order{}
  returns: List of %{store_name: "", total: %Money{}}
  """
  def get_sub_totals_for_order(carts) do
    Enum.map(carts, fn order ->
      %{store_name: order.store_name, total: order.total}
    end)
  end

  def calculate_final_total(tip, total, delivery_fee, service_fee, tax) do
    Money.add(tip, total)
    |> Money.add(delivery_fee)
    |> Money.add(service_fee)
    |> Money.add(tax)
  end
end
