defmodule JaangWeb.Schema.ProductTypes do
  use Absinthe.Schema.Notation
  alias Jaang.Product.Products

  alias JaangWeb.Schema.Middleware

  alias JaangWeb.Resolvers.{
    StoreResolver,
    ProductResolver,
    CategoryResolver,
    SearchResolver
  }

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :product_queries do
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

    ### * Savings / Discounts products
    @desc "Get all on Sale products in store"
    field :get_all_sale_products, list_of(:product) do
      arg(:token, non_null(:string))
      arg(:limit, :integer, default_value: 24)
      arg(:offset, :integer, default_value: 0)
      # middleware(Middleware.Authenticate)

      resolve(&ProductResolver.get_all_sale_products/3)
    end
  end

  object :product_mutations do
    @desc "Return suggest search term"
    field :suggest_search, list_of(:search_term) do
      arg(:token, non_null(:string))

      # middleware(Middleware.Authenticate)
      resolve(&SearchResolver.get_suggest_search/3)
    end
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

  object :search_term do
    field :term, :string
    field :counter, :integer
    field :store_id, :id
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Products, Products.data())

    Map.put(ctx, :loader, loader)
  end
end
