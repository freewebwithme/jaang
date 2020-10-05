defmodule JaangWeb.Schema do
  use Absinthe.Schema
  alias JaangWeb.Resolvers.{StoreResolver, ProductResolver, CategoryResolver, AccountResolver}
  alias Jaang.Product.Products
  alias Jaang.Account.Accounts
  alias JaangWeb.Schema.Middleware

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  query do
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

    @desc "get product"
    field :get_product, :product do
      arg(:id, :id)
      resolve(&ProductResolver.get_product/3)
    end

    @desc "get all products in category"
    field :get_all_products, list_of(:product) do
      arg(:category_id, :id)
      resolve(&ProductResolver.get_all_products/3)
    end

    @desc "Get products by category"
    field :get_products_by_category, :category do
      arg(:id, :id)
      resolve(&CategoryResolver.get_products_by_category/3)
    end

    @desc "Get products by sub_category"
    field :get_products_by_subcategory, list_of(:product) do
      arg(:id, :id)
      resolve(&CategoryResolver.get_products_by_subcategory/3)
    end

    @desc "Get categories and product for home screen"
    field :get_products_for_homescreen, list_of(:category_homescreen) do
      arg(:limit, :integer, default_value: 10)

      resolve(&StoreResolver.get_products_for_homescreen/3)
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
  end

  object :simple_response do
    field :sent, :boolean
    field :message, :string
  end

  object :user do
    field :id, :id
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

  object :profile do
    field :first_name, :string
    field :last_name, :string
    field :photo_url, :string
    field :phone, :string
    field :store_id, :id
  end

  object :address do
    field :address_line_1, :string
    field :address_line_2, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string
  end

  object :store do
    field :id, :id
    field :name, :string
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
  end

  object :product do
    field :id, :id
    field :name, :string
    field :description, :string

    field :regular_price, :string do
      resolve(fn parent, _, _ ->
        money = Map.get(parent, :regular_price)
        {:ok, Money.to_string(money)}
      end)
    end

    field :sale_price, :string do
      resolve(fn parent, _, _ ->
        case Map.get(parent, :sale_price) do
          nil ->
            {:ok, nil}

          money ->
            {:ok, Money.to_string(money)}
        end
      end)
    end

    field :vendor, :string
    field :published, :boolean
    field :barcode, :string
    field :unit_name, :string
    field :store_name, :string
    field :category_name, :string
    field :sub_category_name, :string
    field :product_images, list_of(:product_image), resolve: dataloader(Products)
  end

  object :product_image do
    field :image_url, :string
    field :default, :boolean
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Products, Products.data())
      |> Dataloader.add_source(Accounts, Accounts.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
