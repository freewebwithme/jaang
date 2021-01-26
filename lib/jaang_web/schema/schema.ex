defmodule JaangWeb.Schema do
  use Absinthe.Schema
  alias Timex

  alias JaangWeb.Resolvers.{
    StoreResolver,
    ProductResolver,
    CategoryResolver,
    AccountResolver,
    CartResolver,
    ProfileResolver,
    PaymentResolver,
    CheckoutResolver,
    OrderResolver,
    SearchResolver
  }

  alias Jaang.Utility

  alias Jaang.Product.Products
  alias Jaang.Account.Accounts
  alias Jaang.Checkout.Carts
  alias JaangWeb.Schema.Middleware

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  query do
    ### * Stores

    @desc "get stores"
    field :get_stores, list_of(:store) do
      middleware(Middleware.Authenticate)
      resolve(&StoreResolver.get_stores/3)
    end

    @desc "get store"
    field :get_store, :store do
      arg(:id, non_null(:string))
      middleware(Middleware.Authenticate)
      resolve(&StoreResolver.get_store/3)
    end

    @desc "Get available delivery datetime for stores"
    field :get_delivery_datetime, list_of(:delivery_datetime) do
      # middleware(Middleware.Authenticate)
      resolve(&StoreResolver.get_delivery_datetime/3)
    end

    ### * Products

    @desc "get product"
    field :get_product, :product do
      arg(:id, :id)
      # middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_product/3)
    end

    @desc "get all products in category"
    field :get_all_products, list_of(:product) do
      arg(:category_id, :id)
      # middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_all_products/3)
    end

    # TODO: Not using this function
    @desc "Get products by category"
    field :get_products_by_category, list_of(:product) do
      arg(:category_id, :string)
      arg(:store_id, :integer)
      arg(:limit, :integer, default_value: 5)
      # middleware(Middleware.Authenticate)
      resolve(&CategoryResolver.get_products_by_category/3)
    end

    @desc "Get products by sub_category and display for each sub category products"
    field :get_products_by_subcategory, list_of(:sub_category) do
      arg(:category_id, :string)
      arg(:store_id, :integer)
      arg(:limit, :integer, default_value: 3)
      # middleware(Middleware.Authenticate)
      resolve(&CategoryResolver.get_products_by_subcategory/3)
    end

    @desc "Get products by sub category name and display in subcategory screen"
    field :get_products_by_subcategory_name, list_of(:product) do
      arg(:category_name, non_null(:string))
      arg(:store_id, non_null(:integer))
      arg(:limit, :integer, default_value: 6)
      arg(:offset, :integer, default_value: 0)
      # middleware(Middleware.Authenticate)

      resolve(&CategoryResolver.get_products_by_subcategory_name/3)
    end

    @desc "Get categories and product for home screen"
    field :get_products_for_homescreen, list_of(:category_homescreen) do
      arg(:limit, :integer, default_value: 10)
      arg(:store_id, non_null(:string))
      # middleware(Middleware.Authenticate)

      resolve(&StoreResolver.get_products_for_homescreen/3)
    end

    @desc "Get related product using product tag"
    field :get_related_products, list_of(:product) do
      arg(:product_id, non_null(:string))
      arg(:tag_id, non_null(:string))
      arg(:limit, :integer, default_value: 5)
      arg(:store_id, non_null(:string))
      middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_related_products/3)
    end

    @desc "Get often bought with product using recipe tag"
    field :get_often_bought_with_products, list_of(:product) do
      arg(:product_id, non_null(:string))
      arg(:tag_id, non_null(:string))
      arg(:limit, :integer, default_value: 5)
      arg(:store_id, non_null(:string))
      middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_often_bought_with_products/3)
    end

    ### * Category
    @desc "Get all categories"
    field :list_categories, list_of(:category) do
      resolve(&ProductResolver.list_categories/3)
    end

    ### * Product search

    @desc "Search products"
    field :search_products, list_of(:product) do
      arg(:terms, non_null(:string))
      arg(:token, non_null(:string))
      arg(:limit, :integer, default_value: 12)
      arg(:offset, :integer, default_value: 0)

      # middleware(Middleware.Authenticate)
      resolve(&SearchResolver.search_products/3)
    end

    @desc "Return suggest search term"
    field :suggest_search, list_of(:search_term) do
      arg(:token, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&SearchResolver.get_suggest_search/3)
    end

    ### * Carts
    @desc "Get all carts that has not been checked out"
    field :get_all_carts, :carts do
      arg(:user_id, non_null(:string))
      # middleware(Middleware.Authenticate)
      resolve(&CartResolver.get_all_carts/3)
    end

    ### * Savings / Discounts products
    @desc "Get all on Sale products in store"
    field :get_all_sale_products, list_of(:product) do
      arg(:token, non_null(:string))
      arg(:limit, :integer, default_value: 24)
      arg(:offset, :integer, default_value: 0)
      # middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_all_sale_products/3)
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

  mutation do
    @desc "Log in an user"
    field :log_in, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&AccountResolver.log_in/3)
    end

    @desc "Register an user"
    field :sign_up, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:password_confirmation, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))

      resolve(&AccountResolver.sign_up/3)
    end

    @desc "Reset password"
    field :reset_password, :simple_response do
      arg(:email, non_null(:string))

      resolve(&AccountResolver.reset_password/3)
    end

    @desc "Google Sign in"
    field :google_signin, :session do
      arg(:email, non_null(:string))
      arg(:display_name, :string)
      arg(:photo_url, :string)

      resolve(&AccountResolver.google_signIn/3)
    end

    @desc "Log out"
    field :log_out, :session do
      arg(:token, :string)
      middleware(Middleware.Authenticate)

      resolve(&AccountResolver.log_out/3)
    end

    @desc "Verify session token from client"
    field :verify_token, :session do
      arg(:token, non_null(:string))

      resolve(&AccountResolver.verify_token/3)
    end

    @desc "Change current store for user"
    field :change_store, :session do
      arg(:token, non_null(:string))
      arg(:store_id, non_null(:string))
      middleware(Middleware.Authenticate)

      resolve(&StoreResolver.change_store/3)
    end

    # Address
    @desc "Update address"
    field :update_address, :session do
      arg(:user_token, non_null(:string))
      arg(:recipient, non_null(:string))
      arg(:address_id, non_null(:string))
      arg(:address_line_one, :string)
      arg(:address_line_two, :string)
      arg(:business_name, :string)
      arg(:zipcode, :string)
      arg(:city, :string)
      arg(:state, :string)
      arg(:instructions, :string)

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.update_address/3)
    end

    @desc "Change default address"
    field :change_default_address, :session do
      arg(:user_token, non_null(:string))
      arg(:address_id, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.change_default_address/3)
    end

    @desc "Add a new address"
    field :add_address, :session do
      arg(:user_token, non_null(:string))
      arg(:recipient, non_null(:string))
      arg(:address_line_one, non_null(:string))
      arg(:address_line_two, :string)
      arg(:business_name, :string)
      arg(:zipcode, non_null(:string))
      arg(:city, non_null(:string))
      arg(:state, non_null(:string))
      arg(:instructions, :string)

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.add_address/3)
    end

    @desc "Delete address"
    field :delete_address, :session do
      arg(:user_token, non_null(:string))
      arg(:address_id, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.delete_address/3)
    end

    @desc "Update profile information"
    field :update_profile, :session do
      arg(:user_token, non_null(:string))
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:phone, :string)
      arg(:photo_url, :string)

      # middleware(Middleware.Authenticate)
      resolve(&ProfileResolver.update_profile/3)
    end

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

    @desc "Calculate total amount for checkout screen"
    field :calculate_total_amount, :total_amount do
      arg(:tip, :string)
      arg(:token, :string)
      arg(:delivery_time, :string)

      # middleware(Middleware.Authenticate)
      resolve(&CheckoutResolver.calculate_total/3)
    end

    @desc "Place an order"
    field :place_order, :invoice do
      arg(:token, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&CheckoutResolver.place_an_order/3)
    end
  end

  object :delivery_datetime do
    field :delivery_day, :string
    field :delivery_date, :string
    field :delivery_month, :string
    field :available_hours, list_of(:string)
  end

  object :invoice do
    field :id, :id
    field :invoice_number, :string
    field :subtotal, :string
    field :driver_tip, :string
    field :delivery_fee, :string
    field :service_fee, :string
    field :sales_tax, :string
    field :item_adjustment, :string
    field :total, :string
    field :payment_method, :string
    field :pm_intent_id, :string
    field :status, :string
    field :user_id, :id
    field :total_items, :integer
    # Add delivery address information
    field :recipient, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string

    field :phone_number, :string
    field :delivery_time, :string
    # Orders
    field :orders, list_of(:order), resolve: dataloader(Carts)

    field :updated_at, :string do
      resolve(fn parent, _, _ ->
        updated_at = Map.get(parent, :updated_at)
        Utility.convert_and_format_datetime(updated_at)
      end)
    end
  end

  object :simple_response do
    field :sent, :boolean
    field :message, :string
  end

  object :user do
    field :id, :id
    field :stripe_id, :string
    field :email, :string
    field :confirmed_at, :string
    field :profile, :profile, resolve: dataloader(Accounts)
    field :addresses, list_of(:address), resolve: dataloader(Accounts)
  end

  object :session do
    field :user, :user
    field :token, :string
    field :expired, :boolean, default_value: false
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
    field :id, :id
    field :store_id, :id
    field :store_name, :string
    field :store_logo, :string
    field :user_id, :id
    field :status, :string
    field :available_checkout, :boolean, default_value: false
    field :required_amount, :string

    field :total, :string

    field :line_items, list_of(:line_item)
  end

  object :line_item do
    field :product_id, :id
    field :store_id, :integer
    field :image_url, :string
    field :product_name, :string
    field :unit_name, :string
    field :quantity, :integer

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

  object :profile do
    field :first_name, :string
    field :last_name, :string
    field :photo_url, :string

    field :phone, :string do
      resolve(fn parent, _, _ ->
        phone_number = Map.get(parent, :phone)

        cond do
          is_nil(phone_number) || phone_number == "" ->
            {:ok, phone_number}

          true ->
            area_code = String.slice(phone_number, 0, 3)
            head = String.slice(phone_number, 3, 3)
            tail = String.slice(phone_number, 6, 4)
            formatted = "(#{area_code})#{head}-#{tail}"
            {:ok, formatted}
        end
      end)
    end

    field :store_id, :id
  end

  object :address do
    field :id, :id
    field :recipient, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string
    field :default, :boolean
    field :distance, :distance, resolve: dataloader(Accounts)
  end

  object :distance do
    field :address_id, :id
    field :store_distances, list_of(:store_distance)
  end

  object :store_distance do
    field :store_name, :string
    field :store_id, :id
    field :distance, :float
    field :delivery_available, :boolean
  end

  object :store do
    field :id, :id
    field :name, :string
    field :store_logo, :string
    field :description, :string
    field :price_info, :string
    field :phone_number, :string
    field :address, :string
    field :available_hours, :string
    # field :product, list_of(:product), resolve: dataloader(Products)
  end

  object :category do
    field :id, :id
    field :name, :string
    field :description, :string
    field :sub_categories, list_of(:sub_category), resolve: dataloader(Products)
    field :products, list_of(:product), resolve: dataloader(Products)
  end

  object :category_homescreen do
    field :id, :id
    field :name, :string
    field :sub_categories, list_of(:sub_category), resolve: dataloader(Products)

    field :products, list_of(:product) do
      resolve(fn parent, _, _ ->
        {:ok, parent.products}
      end)
    end
  end

  object :sub_category do
    field :name, :string
    field :id, :id

    field :products, list_of(:product) do
      resolve(fn parent, _, _ ->
        {:ok, parent.products}
      end)
    end
  end

  object :sub_category_product do
    field :id, :id
    field :name, :string
    field :products, list_of(:product)
  end

  object :product do
    field :id, :id
    field :name, :string
    field :description, :string
    field :ingredients, :string
    field :directions, :string
    field :warnings, :string

    field :product_prices, list_of(:product_price)

    field :vendor, :string
    field :published, :boolean
    field :barcode, :string
    field :unit_id, :string
    field :unit_name, :string
    field :store_name, :string
    field :store_id, :integer
    field :category_name, :string
    field :category_id, :integer
    field :sub_category_name, :string
    field :sub_category_id, :integer
    field :product_images, list_of(:product_image), resolve: dataloader(Products)
    field :tags, list_of(:tag), resolve: dataloader(Products)
    field :recipe_tags, list_of(:recipe_tag), resolve: dataloader(Products)
  end

  object :product_price do
    field :start_date, :string
    field :end_date, :string
    field :discount_percentage, :string
    field :on_sale, :boolean
    field :original_price, :string
    field :sale_price, :string
    field :product_id, :id
  end

  object :product_image do
    field :image_url, :string
    field :order, :integer
  end

  object :tag do
    field :id, :id
    field :name, :string
  end

  object :recipe_tag do
    field :id, :id
    field :name, :string
  end

  object :credit_card do
    field :brand, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :last_four, :string
    field :payment_method_id, :string
    field :default_card, :boolean
  end

  object :total_amount do
    field :driver_tip, :string
    field :sub_totals, list_of(:sub_total)
    field :delivery_fee, :string
    # field :service_fee, :string
    field :sales_tax, :string
    field :item_adjustments, :string
    field :total, :string
  end

  object :sub_total do
    field :store_name, :string
    field :total, :string
  end

  object :search_term do
    field :term, :string
    field :counter, :integer
    field :store_id, :id
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Products, Products.data())
      |> Dataloader.add_source(Accounts, Accounts.data())
      |> Dataloader.add_source(Carts, Carts.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
