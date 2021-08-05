defmodule Jaang.Invoice.StoreTotalAmount do
  defstruct driver_tip: Money.new(0),
            delivery_fee: Money.new(0),
            sales_tax: Money.new(0),
            item_adjustment: Money.new(0),
            total: Money.new(0),
            grand_total: Money.new(0),
            grand_final_total: Money.new(0)
end
