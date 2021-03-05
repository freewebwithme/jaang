defmodule Jaang.Admin.Shoppers do
  @moduledoc """
  Module for shopper functions
  1. find best available shopper
  2. review shopper
  """
  import Ecto.Query
  alias Jaang.Admin.Account.Employee.Employee

  def get_shoppers_by_store(store_id) do
    Repo.all(from e in Employee, where: e.assigned_store_id == ^store_id)
  end
end
