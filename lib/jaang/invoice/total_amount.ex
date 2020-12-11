defmodule Jaang.Invoice.TotalAmount do
  defstruct driver_tip: Money.new(0),
            delivery_fee: Money.new(0),
            service_fee: Money.new(0),
            sales_tax: Money.new(0),
            item_adjustments: Money.new(0),
            total: Money.new(0),
            sub_totals: []
end
