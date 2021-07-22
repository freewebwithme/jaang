defmodule Jaang.Checkout.Calculate do
  @tax_rate 0.095
  @delivery_fee 499
  @item_adjustment 0.15
  @service_fee 0.08

  @doc """
  Calculate service fee
  params : type %Money{} = total_amount
  """
  def calculate_service_fee(total_amount) do
    Money.multiply(total_amount, @service_fee)
  end

  @doc """
  Los Angeles city tax rate is 9.5%
  Exclude produce product from tax
  params: carts(list of order)

  return: tax = Money{amount: tax, currency: :USD}
  """

  # ! TODO: Remove this function
  # def calculate_sales_tax(carts, status) do
  #  # Get total of carts exclude produce product total
  #  # get all lineItems excluding Produce
  #  total_excluding_produce =
  #    Enum.flat_map(carts, & &1.line_items)
  #    |> Enum.filter(&(&1.category_name != "Produce"))
  #    |> Enum.filter(&(&1.status == status))
  #    |> Enum.reduce(Money.new(0), fn line_item, acc ->
  #      Money.add(line_item.total, acc)
  #    end)

  #  Money.multiply(total_excluding_produce, @tax_rate)
  # end

  @doc """
  Los Angeles city tax rate is 9.5%
  Exclude produce product from tax
  params: cart(order) for each store

  return: tax = Money{amount: tax, currency: :USD}
  """
  def calculate_sales_tax_for_store(order, status) do
    total_price_excluding_produce_product =
      Enum.filter(order.line_items, &(&1.category_name != "Produce"))
      |> Enum.filter(&(&1.status == status))
      |> Enum.reduce(Money.new(0), fn line_item, acc ->
        Money.add(line_item.total, acc)
      end)

    Money.multiply(total_price_excluding_produce_product, @tax_rate)
  end

  def get_delivery_fee(), do: Money.new(@delivery_fee)

  def calculate_delivery_fee(carts) do
    store_count = Enum.count(carts)
    Money.multiply(Money.new(@delivery_fee), store_count)
  end

  def calculate_item_adjustments(total_amount) do
    Money.multiply(total_amount, @item_adjustment)
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

  @doc """
  This function sums up all cost including
  total, tax, item_adjustment, driver_tip and delivery fee
  """
  def calculate_grand_total_for_store(total, sales_tax, item_adjustment, driver_tip, delivery_fee) do
    Money.add(total, sales_tax)
    |> Money.add(item_adjustment)
    |> Money.add(driver_tip)
    |> Money.add(delivery_fee)
  end

  def calculate_subtotals(carts) do
    Enum.reduce(carts, Money.new(0), fn cart, acc ->
      Money.add(acc, cart.total)
    end)
  end

  @doc """
  Sum up every amount
  """
  def calculate_final_total(tip, total, delivery_fee, tax, item_adjustments) do
    Money.add(tip, total)
    |> Money.add(delivery_fee)
    |> Money.add(tax)
    |> Money.add(item_adjustments)
  end
end
