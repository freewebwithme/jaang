defmodule Jaang.Checkout.Calculate do
  alias Jaang.Invoice
  @tax_rate 0.095
  @delivery_fee 499
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
  params: cart(order) for each store

  return: tax = Money{amount: tax, currency: :USD}
  """
  def calculate_sales_tax_for_store(order, status) do
    total_price_excluding_produce_product =
      Enum.filter(order.line_items, &(&1.category_name != "Produce"))
      |> Enum.filter(&(&1.status == status))
      |> Enum.reduce(Money.new(0), fn line_item, acc ->
        if(line_item.replaced) do
          Money.add(line_item.replacement_item.total, acc)
        else
          Money.add(line_item.total, acc)
        end
      end)

    Money.multiply(total_price_excluding_produce_product, @tax_rate)
  end

  def get_delivery_fee(), do: Money.new(@delivery_fee)

  def calculate_delivery_fee(carts) do
    store_count = Enum.count(carts)
    Money.multiply(Money.new(@delivery_fee), store_count)
  end

  def calculate_item_adjustment(cart) do
    # get a max expected value of total order price
    # get weight based product
    weight_based_line_items = Enum.filter(cart.line_items, &(&1.weight_based == true))
    # Calculate weight_based line items' item adjust ment
    IO.puts("Weight based items length")
    IO.inspect(Enum.count(weight_based_line_items))

    weight_based_item_adjustment =
      Enum.reduce(weight_based_line_items, Money.new(0), fn line_item, acc ->
        if(line_item.has_replacement) do
          # has replacement item, need to check which original price is
          # greater.
          compare_result =
            Money.compare(line_item.original_price, line_item.replacement_item.original_price)

          if(compare_result < 0) do
            # replacement item's price is greater, use it
            weight_limit = line_item.quantity + 0.2

            max_line_item_total =
              Money.multiply(line_item.replacement_item.original_price, weight_limit)

            item_adjustment =
              Money.subtract(max_line_item_total, line_item.replacement_item.total)

            Money.add(item_adjustment, acc)
          else
            weight_limit = line_item.quantity + 0.2

            max_line_item_total = Money.multiply(line_item.original_price, weight_limit)

            item_adjustment = Money.subtract(max_line_item_total, line_item.total)
            Money.add(item_adjustment, acc)
          end
        else
          weight_limit = line_item.quantity + 0.2

          max_line_item_total = Money.multiply(line_item.original_price, weight_limit)

          item_adjustment = Money.subtract(max_line_item_total, line_item.total)
          Money.add(item_adjustment, acc)
        end
      end)

    # Not weight-based items
    not_weight_based_line_items = Enum.filter(cart.line_items, &(&1.weight_based == false))

    IO.puts("Not Weight based items length")
    IO.inspect(Enum.count(not_weight_based_line_items))

    not_weight_based_item_adjustment =
      Enum.reduce(not_weight_based_line_items, Money.new(0), fn line_item, acc ->
        if(line_item.has_replacement) do
          compare_result =
            Money.compare(line_item.original_price, line_item.replacement_item.original_price)

          if(compare_result < 0) do
            # replacement item's price is greater, use it

            item_adjustment =
              Money.subtract(line_item.replacement_item.original_price, line_item.original_price)

            Money.multiply(item_adjustment, line_item.quantity)
            |> Money.add(acc)
          else
            Money.add(Money.new(0), acc)
          end
        else
          Money.add(Money.new(0), acc)
        end
      end)

    # IO.puts("printing not-weight based adjustment")
    # IO.inspect(not_weight_based_item_adjustment)
    # IO.puts("printing weight based adjustment")
    # IO.inspect(weight_based_item_adjustment)
    Money.add(weight_based_item_adjustment, not_weight_based_item_adjustment)
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

  @doc """
  Sum up line_item total(Calculate total of order(cart))
  """
  def calculate_total(order, status) do
    Enum.filter(order.line_items, &(&1.status == status))
    |> Enum.reduce(Money.new(0), fn line_item, acc ->
      if(line_item.replaced) do
        Money.add(acc, line_item.replacement_item.total)
      else
        Money.add(acc, line_item.total)
      end
    end)
  end

  @doc """
  Sum up every amount for one order
  """
  def calculate_final_total(tip, total, delivery_fee, tax, item_adjustments) do
    Money.add(tip, total)
    |> Money.add(delivery_fee)
    |> Money.add(tax)
    |> Money.add(item_adjustments)
  end

  def calculate_grand_final_for_invoice(invoice) do
    Enum.reduce(invoice.orders, Money.new(0), fn order, acc ->
      Money.add(order.grand_total, acc)
    end)
  end

  @doc """
  Count total items in the all carts
  """
  def count_all_total_items(invoice = %Invoice{}) do
    Enum.reduce(invoice.orders, 0, fn order, acc ->
      order.total_items + acc
    end)
  end

  def count_total_item_all_carts(carts) do
    Enum.reduce(carts, 0, fn cart, acc ->
      Enum.count(cart.line_items) + acc
    end)
  end

  @doc """
  Count total items in 1 order
  """
  def count_total_item(order, status) do
    Enum.filter(order.line_items, &(&1.status == status)) |> Enum.count()
  end

  @doc """
  Calculate total price in the all carts(including sales tax, etc)
  """
  def calculate_grand_total_price(carts) do
    Enum.reduce(carts, Money.new(0), fn cart, acc ->
      if(cart.grand_total == nil) do
        Money.add(Money.new(0), acc)
      else
        Money.add(cart.grand_total, acc)
      end
    end)
  end

  def calculate_total_price(carts) do
    Enum.reduce(carts, Money.new(0), fn cart, acc ->
      Money.add(cart.total, acc)
    end)
  end
end
