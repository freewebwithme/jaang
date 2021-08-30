defmodule JaangWeb.Schema.CartTypes do
  use Absinthe.Schema.Notation

  alias Jaang.Admin.Account.Employee.EmployeeAccounts

  alias JaangWeb.Schema.Middleware
  alias JaangWeb.Resolvers.{CartResolver, PaymentResolver, OrderResolver, CheckoutResolver}
  alias Jaang.Utility
  alias Jaang.Checkout.Carts
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :cart_queries do
    ### * Carts
    @desc "Get all carts that has not been checked out"
    field :get_all_carts, :carts do
      arg(:user_id, non_null(:string))
      # middleware(Middleware.Authenticate)
      resolve(&CartResolver.get_all_carts/3)
    end

    ### * Stripe

    @desc "Get all credit cards for user"
    field :get_all_credit_cards, list_of(:credit_card) do
      arg(:user_token, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&PaymentResolver.get_all_cards/3)
    end

    ### * Invoices

    @desc "Fetch user's invoices for orders screen"
    field :fetch_invoices, list_of(:invoice) do
      arg(:token, non_null(:string))
      arg(:limit, :integer, default_value: 10)
      arg(:offset, :integer, default_value: 0)

      # middleware(Middleware.Authenticate)
      resolve(&OrderResolver.fetch_invoices/3)
    end
  end

  object :cart_mutations do
    ### * Credit Card

    @desc "Attach a payment method to user"
    field :attach_payment_method, list_of(:credit_card) do
      arg(:user_token, non_null(:string))
      arg(:card_token, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&PaymentResolver.attach_payment_method/3)
    end

    @desc "Change payment method"
    field :change_payment_method, list_of(:credit_card) do
      arg(:user_token, non_null(:string))
      arg(:payment_method_id, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&PaymentResolver.change_payment_method/3)
    end

    @desc "Delete payment method"
    field :delete_payment_method, list_of(:credit_card) do
      arg(:user_token, non_null(:string))
      arg(:payment_method_id, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&PaymentResolver.delete_payment_method/3)
    end

    ### * Cart
    @desc "Add item to cart"
    field :add_to_cart, :carts do
      arg(:user_id, non_null(:string))
      arg(:product_id, non_null(:string))
      arg(:quantity, non_null(:integer))
      arg(:store_id, non_null(:integer))

      # middleware(Middleware.Authenticate)

      resolve(&CartResolver.add_to_cart/3)
    end

    @desc "Update a cart, change a quantity of item or delete a item from cart"
    field :update_cart, :carts do
      arg(:user_id, non_null(:string))
      arg(:product_id, non_null(:string))
      arg(:quantity, non_null(:integer))
      arg(:store_id, non_null(:integer))

      # middleware(Middleware.Authenticate)
      resolve(&CartResolver.update_cart/3)
    end

    ### * Calculate total amount

    @desc "Calculate total amount for store for checkout screen"
    field :calculate_total_amount_for_store, :store_total_amount do
      arg(:tip, non_null(:string))
      arg(:token, non_null(:string))
      arg(:order_id, non_null(:integer))

      # middleware(Middleware.Authenticate)
      resolve(&CheckoutResolver.calculate_total_for_store/3)
    end

    @desc "Refund request"
    field :request_refund, :order do
      arg(:token, non_null(:string))
      arg(:order_id, non_null(:integer))
      arg(:refund_items, list_of(:refund_item))

      # middleware(Middleware.Authenticate)
      resolve(&OrderResolver.request_refund/3)
    end
  end

  @desc "Refund items input object"
  input_object :refund_item do
    field :line_item_id, :string
    field :quantity, :integer
    field :refund_reason, :string
  end

  object :refund_request do
    field :status, :string
    field :subtotal, :string
    field :sales_tax, :string
    field :total_refund, :string
    field :user_id, :id
    field :order_id, :id
    field :refund_items, list_of(:line_item)
  end

  object :delivery_datetime do
    field :delivery_day, :string
    field :delivery_date, :string
    field :delivery_month, :string
    field :delivery_year, :string
    field :available_hours, list_of(:string)
  end

  object :invoice do
    field :id, :integer
    field :invoice_number, :string
    field :payment_method, :string
    field :pm_intent_id, :string
    field :status, :string
    field :user_id, :id
    field :total_items, :integer
    field :grand_total_price, :string
    # Orders
    field :orders, list_of(:order), resolve: dataloader(Carts)

    field :invoice_placed_at, :string do
      resolve(fn parent, _, _ ->
        invoice_placed_at = Map.get(parent, :invoice_placed_at)
        Utility.convert_and_format_datetime(invoice_placed_at)
      end)
    end

    field :updated_at, :string do
      resolve(fn parent, _, _ ->
        updated_at = Map.get(parent, :updated_at)
        Utility.convert_and_format_datetime(updated_at)
      end)
    end

    field :employees, list_of(:employee), resolve: dataloader(EmployeeAccounts)
  end

  object :carts do
    field :orders, list_of(:order)
    field :total_items, :integer

    field :total_price, :string do
      resolve(fn parent, _, _ ->
        money = Map.get(parent, :total_price)
        {:ok, Money.to_string(money)}
      end)
    end
  end

  object :order do
    field :id, :integer
    field :store_id, :id
    field :store_name, :string
    field :store_logo, :string
    field :user_id, :id
    field :status, :string
    field :available_checkout, :boolean, default_value: false
    field :required_amount, :string

    field :total, :string

    field :line_items, list_of(:line_item)

    # add new information
    field :delivery_time, :string
    # field :delivery_date, :date
    field :delivery_order, :integer
    field :delivery_fee, :string
    field :delivery_tip, :string
    field :sales_tax, :string
    field :item_adjustment, :string
    field :total_items, :integer
    field :number_of_bags, :integer, default_value: 0
    field :instruction, :string

    field :recipient, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string

    field :grand_total, :string

    field :phone_number, :string

    field :updated_at, :string do
      resolve(fn parent, _, _ ->
        updated_at = Map.get(parent, :updated_at)
        Utility.convert_and_format_datetime(updated_at)
      end)
    end

    field :order_placed_at, :string do
      resolve(fn parent, _, _ ->
        order_placed_at = Map.get(parent, :order_placed_at)
        Utility.convert_and_format_datetime(order_placed_at)
      end)
    end

    # ex) hand over to customer, leave at the front door
    field :delivery_method, :string

    field :receipt_photos, list_of(:receipt_photo)
    field :refund_request, :refund_request, resolve: dataloader(Carts)
  end

  object :receipt_photo do
    field :photo_url, :string
  end

  object :line_item do
    field :id, :string
    field :product_id, :id
    field :store_id, :integer
    field :image_url, :string
    field :product_name, :string
    field :unit_name, :string
    field :quantity, :integer
    field :category_name, :string
    field :weight, :float
    field :barcode, :string
    field :weight_based, :boolean
    field :final_quantity, :integer
    field :note, :string
    field :has_replacement, :boolean
    field :replacement_id, :integer
    field :replaced, :boolean
    field :replacement_item, :line_item
    field :status, :string

    field :price, :string do
      resolve(fn parent, _, _ ->
        money = Map.get(parent, :price)
        {:ok, Money.to_string(money)}
      end)
    end

    field :total, :string do
      resolve(fn parent, _, _ ->
        money = Map.get(parent, :total)
        {:ok, Money.to_string(money)}
      end)
    end
  end

  object :credit_card do
    field :brand, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :last_four, :string
    field :payment_method_id, :string
    field :default_card, :boolean
  end

  object :store_total_amount do
    field :driver_tip, :string
    field :delivery_fee, :string
    field :sales_tax, :string
    field :item_adjustment, :string
    field :total, :string
    field :grand_total, :string
    field :grand_final_total, :string
  end

  object :sub_total do
    field :store_name, :string
    field :total, :string
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Carts, Carts.data())

    Map.put(ctx, :loader, loader)
  end
end
