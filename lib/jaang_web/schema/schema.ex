defmodule JaangWeb.Schema do
  use Absinthe.Schema
  alias Timex

  alias Jaang.Checkout.Carts
  alias Jaang.Account.Accounts
  alias Jaang.Product.Products
  alias Jaang.Admin.Account.Employee.EmployeeAccounts

  import_types(JaangWeb.Schema.ProductTypes)
  import_types(JaangWeb.Schema.AccountTypes)
  import_types(JaangWeb.Schema.CartTypes)
  import_types(JaangWeb.Schema.StoreTypes)

  # Employee
  import_types(JaangWeb.Schema.Employee.EmployeeAccountTypes)

  query do
    import_fields(:store_queries)
    import_fields(:product_queries)
    import_fields(:cart_queries)
  end

  mutation do
    import_fields(:account_mutations)
    import_fields(:store_mutations)
    import_fields(:cart_mutations)
    import_fields(:product_mutations)

    # Employee
    import_fields(:employee_account_mutations)
  end

  object :simple_response do
    field :sent, :boolean
    field :message, :string
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Carts, Carts.data())
      |> Dataloader.add_source(Accounts, Accounts.data())
      |> Dataloader.add_source(Products, Products.data())
      |> Dataloader.add_source(EmployeeAccounts, EmployeeAccounts.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
