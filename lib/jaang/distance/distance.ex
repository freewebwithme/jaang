defmodule Jaang.Distance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Jaang.{AccountManager, StoreManager, ProfileManager, OrderManager}
  alias Jaang.Account.Addresses
  alias Jaang.Repo
  alias Jaang.Distance
  alias Jaang.Distance.StoreDistance

  schema "distances" do
    embeds_many :store_distances, StoreDistance, on_replace: :delete
    belongs_to :address, Jaang.Account.Address
  end

  @doc false
  def changeset(%Distance{} = distance, attrs) do
    distance
    |> cast(attrs, [:address_id])
    |> cast_embed(:store_distances, with: &StoreDistance.changeset/2)
  end

  @doc """
  Create distance schema along with address.
  params: user_id, and newly created address

  There are 2 situations to be called this function.

  1. While checkout process, user can add a new address.
  In this case, I need to check carts for stores, to check
  if newly added address is available to delivery to the stores
  in the carts.

  2. In Address screen, user can add new address.
  In this case, I don't have to check check stores in the carts
  Just create distance between default store address and
  newly added address
  """
  def create_distance(user_id, address) do
    user_address = Addresses.build_address(address)

    # In case or most case, user adds address while checking out the carts.
    # So I need to check if current stores in carts, also available to deliver
    # in case of multiple stores in the cart

    # get carts
    carts = OrderManager.get_all_carts(user_id)

    case Enum.count(carts) == 0 do
      true ->
        # Carts is empty, just check distance for default store
        user = AccountManager.get_user(user_id)
        default_store = StoreManager.get_store(user.profile.store_id)

        {distance, delivery_available} =
          StoreDistance.delivery_available?(default_store.address, user_address)

        %Distance{}
        |> changeset(%{
          address_id: address.id,
          store_distance: [
            %{
              store_id: default_store.id,
              store_name: default_store.name,
              distance: distance,
              delivery_available: delivery_available
            }
          ]
        })
        |> Repo.insert()

      _ ->
        # Calculate distance agains stores that are in cart
        store_distances =
          Enum.map(carts, & &1.store_id)
          |> Enum.map(fn id ->
            StoreManager.get_store(id)
          end)
          |> Enum.map(fn store ->
            {distance, delivery_available} =
              StoreDistance.delivery_available?(store.address, user_address)

            %{
              store_id: store.id,
              store_name: store.name,
              distance: distance,
              delivery_available: delivery_available
            }
          end)

        IO.puts("Printing store_distances from #{__MODULE__}")
        IO.inspect(store_distances)

        %Distance{}
        |> changeset(%{
          address_id: address.id,
          store_distances: store_distances
        })
        |> Repo.insert()
    end
  end

  def update_distance(%Distance{} = distance, attrs) do
    distance
    |> changeset(attrs)
    |> Repo.update!()
  end

  def delete_distance(%Distance{} = distance) do
    distance |> Repo.delete!()
  end

  @doc """
  When a user changes default store (selecting store from select store screen)
  Check if user's default address is available to deliver to new default store.

  """
  def check_and_update_store_distance(user, store_id) do
    # Get default store
    store = Jaang.StoreManager.get_store(store_id)
    # Get user's default address
    default_address = ProfileManager.get_default_address(user.addresses)

    if(default_address.distance == nil) do
      # There is no distance schema. create one
      create_distance(user.id, default_address)
    else
      # There is distance schema, then check if distance
      # has store info
      store_distances = default_address.distance.store_distances

      if(Enum.any?(store_distances, &(&1.store_id == store_id))) do
        # has current store information do nothing
        IO.puts("Store distance information found #{__MODULE__}")
        nil
      else
        # No current store information, put a new store information

        user_address = ProfileManager.build_address(default_address)

        {distance, delivery_available} =
          Distance.StoreDistance.delivery_available?(store.address, user_address)

        # Convert from StoreDistance schema from Struct
        existing_store_distances = store_distances |> Enum.map(&Map.from_struct/1)
        # Update distance schema adding new store distance information
        attrs = %{
          address_id: default_address.id,
          store_distances: [
            %{
              store_id: store.id,
              store_name: store.name,
              distance: distance,
              delivery_available: delivery_available
            }
            | existing_store_distances
          ]
        }

        update_distance(default_address.distance, attrs)
      end
    end
  end
end
