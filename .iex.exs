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


id_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjllYWEwMjZmNjM1MTU3ZGZhZDUzMmU0MTgzYTZiODIzZDc1MmFkMWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzNDUzNDY3MDYxNTQtYWlubGZmcWsyMmlxNGNlaTVudWp1OGZ0MmpmYWQxcGQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIzNDUzNDY3MDYxNTQtbHUyYjdyanY0Z3JidHNlNGtzOHFkMG5pZWs3YzNjMTcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDgxMzIwMTYxNDc4ODE3NjI3NDAiLCJlbWFpbCI6InJlZGxlb3BhcmQ4MUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IlRhZWh3YW4gS2ltIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hLS9BT2gxNEdpc2RmQ19vWGtQYU54SlYtaXA4RjRsaVUzT2F6YkdiLWRFYXBBaDVnPXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6IlRhZWh3YW4iLCJmYW1pbHlfbmFtZSI6IktpbSIsImxvY2FsZSI6ImVuIiwiaWF0IjoxNjQzODQ5MjQ3LCJleHAiOjE2NDM4NTI4NDd9.V00iHxyqZPVZHajyeUqqFL4i19RqZm8X91oJA1UcWvQHaTBfQVHPbDUSynJYZ6xmUV35R9r1eOL7K77J1EwLvUWAA51ptmXGjFjjr4Njy9S2ONltP5W31U7ip_F74S4u_7V2aygmC3G_FA1vxQQq_6Z0xWQlToTxH-6RfhMnSJvK4_Hr-C95Nb6twE63pmtgM0HrDHsGXnvptNzR00jAjAML6ue-xvN5zu_KdjjehxN-RIAvAySiSRwWk0ozSavyViuog7Iu4oFmnelp-h-uYXU-758ywILKntM68ClbEQ5tF1_l_EBNoB9BDtSyNI97ElM0EPzUoZ6v_AcqztL1hw"
