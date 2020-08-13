defmodule JaangWeb.Schema do
  use Absinthe.Schema
  alias JaangWeb.Resolvers.{StoreResolver, ProductResolver, CategoryResolver}
  alias Jaang.Product.Products

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  query do
    @desc "get stores"
    field :get_stores, list_of(:store) do
      resolve(&StoreResolver.get_stores/3)
    end

    @desc "get store"
    field :get_store, :store do
      arg(:id, :id)
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
  end

  object :store do
    field :id, :id
    field :name, :string
    field :description, :string
    field :price_info, :string
    field :available_hours, :string
  end

  object :category do
    field :name, :string
    field :sub_categories, list_of(:sub_category)
    field :products, list_of(:product), resolve: dataloader(Products)
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

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
