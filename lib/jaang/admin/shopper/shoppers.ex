defmodule Jaang.Admin.Shoppers do
  @moduledoc """
  Module for shopper functions
  1. find best available shopper
  2. review shopper
  """
  alias Jaang.Admin.Account.Employee.Employee
  alias Jaang.Admin.Store.Stores

  # How can I find best available shoper?
  # conditions -
  # 1. shopper who is currently not fulfilling order
  # 2. shopper who has better feedback(review)
  # 3. shopper who has better time record for fulfilling order(faster shopping time)

  def get_best_available_shopper(store_id) do
    # Get employee list from store
    store = Stores.get_store_with_employees(store_id)
    # Get only shoppers
    shoppers =
      Enum.filter(store.employees, fn employee ->
        Enum.any?(employee.roles, fn role -> role.name == "Shopper" end)
      end)
  end
end
