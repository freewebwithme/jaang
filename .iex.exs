# IEx.configure colors: [enabled: true]
# IEx.configure colors: [ eval_result: [ :cyan, :bright ] ]
IO.puts(
  IO.ANSI.red_background() <>
    IO.ANSI.white() <> " ❄❄❄ No Other Name, Only Jesus ❄❄❄ " <> IO.ANSI.reset()
)

Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  colors: [
    eval_result: [:green, :bright],
    eval_error: [[:red, :bright, "Bug Bug ..!!"]],
    eval_info: [:yellow, :bright]
  ],
  default_prompt:
    [
      # ANSI CHA, move cursor to column 1
      "\e[G",
      :white,
      "I",
      :red,
      # plain string
      "❤",
      :green,
      "Jesus",
      :white,
      "|",
      :blue,
      "%counter",
      :white,
      "|",
      :red,
      # plain string
      "▶",
      :white,
      # plain string
      "▶▶",
      # ❤ ❤-»" ,  # plain string
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)

alias Jaang.Repo
alias Jaang.{Category, Store, Product}
alias Jaang.Category.{Categories, SubCategory}
alias Jaang.Store.Stores

alias Jaang.Product.{
  Products,
  Tag,
  ProductTags,
  RecipieTags,
  ProductImage,
  ProductPrice,
  MarketPrice
}

alias Jaang.{
  StoreManager,
  AccountManager,
  ProductManager,
  OrderManager,
  ProfileManager,
  StripeManager,
  InvoiceManager,
  SearchManager
}

alias Jaang.Account.{User, Account, Profile, Address, Addresses}
alias Jaang.Checkout.{Carts, Order, LineItem, Calculate}
alias Jaang.Invoice
alias Jaang.Invoice.Invoices

# Admin
alias Jaang.Admin.Account.{AdminUser, AdminAccounts}

alias ExAws.S3
alias Stripe
alias Stripe.{Customer}

alias Jaang.Payment.Stripe.{Customer, PaymentMethod, SetupIntent, PaymentIntent}

import Ecto.Query

stripe_id = "cus_IQ6pa99rGTl2KQ"

#### Admin
alias Jaang.Admin.Invoice.Invoices
alias Jaang.Admin.Product.Products
alias Jaang.Admin.Store.Stores
alias Jaang.Admin.Order.Orders
alias Jaang.Admin.Customer.Customers
alias Jaang.Utility
alias Jaang.Admin.Account.Employee.{Employee, EmployeeProfile, EmployeeRole}
alias Jaang.Admin.Account.EmployeeAuthMobile
alias Jaang.Admin.EmployeeAccountManager
alias Jaang.Admin.EmployeeTask
alias Jaang.Admin.EmployeeTask.EmployeeTasks

alias Jaang.Admin.CustomerService.RefundRequest
alias Jaang.Admin.CustomerServices
alias Jaang.Admin.Order.LineItems
