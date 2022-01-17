defmodule Jaang.Admin.ShopperManager do
  alias Jaang.Admin.Shoppers

  defdelegate get_best_available_shopper(store_id), to: Shoppers
end
