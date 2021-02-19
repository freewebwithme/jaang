defmodule JaangWeb.Schema.StoreTypes do
  use Absinthe.Schema.Notation
  alias JaangWeb.Resolvers.StoreResolver
  alias JaangWeb.Schema.Middleware

  object :store_queries do
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
  end

  object :store_mutations do
    @desc "Change current store for user"
    field :change_store, :session do
      arg(:token, non_null(:string))
      arg(:store_id, non_null(:string))
      middleware(Middleware.Authenticate)

      resolve(&StoreResolver.change_store/3)
    end
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
end
