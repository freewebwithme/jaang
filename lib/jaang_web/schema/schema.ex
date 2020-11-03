defmodule JaangWeb.Schema do
  use Absinthe.Schema

  alias JaangWeb.Resolvers.{
    StoreResolver,
    ProductResolver,
    CategoryResolver,
    AccountResolver,
    CartResolver
  }

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
      middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_product/3)
    end

    @desc "get all products in category"
    field :get_all_products, list_of(:product) do
      arg(:category_id, :id)
      middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_all_products/3)
    end

    @desc "Get products by category"
    field :get_products_by_category, :category do
      arg(:category_id, :string)
      arg(:store_id, :integer)
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

    ### * Carts
    @desc "Get all carts that has not been checked out"
    field :get_all_carts, :carts do
      arg(:user_id, non_null(:string))
      # middleware(Middleware.Authenticate)
      resolve(&CartResolver.get_all_carts/3)
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
  end

  ### * Subscription
  subscription do
    @desc "Subscribe to cart changes"
    field :cart_change, :carts do
      arg(:user_id, non_null(:string))

      # middleware(Middleware.Authenticate)

      config(fn arg, _res ->
        {:ok, topic: arg.user_id}
      end)
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
    #    field :carts, list_of(:order)
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
    field :user_id, :id
    field :status, :string

    field :total, :string do
      resolve(fn parent, _, _ ->
        money = Map.get(parent, :total)
        {:ok, Money.to_string(money)}
      end)
    end

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
    field :id, :id
    field :products, list_of(:product)
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
