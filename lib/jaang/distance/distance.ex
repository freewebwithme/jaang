defmodule Jaang.Distance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Jaang.{AccountManager, StoreManager}
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
  """
  def create_distance(user_id, address) do
    IO.puts("Calling create distance")
    user = AccountManager.get_user(user_id)
    # Get Default store
    default_store = StoreManager.get_store(user.profile.store_id)
    user_address = Addresses.build_address(address)

    # Calculate distance
    {distance, delivery_available} =
      StoreDistance.delivery_available?(default_store.address, user_address)

    %Distance{}
    |> changeset(%{
      address_id: address.id,
      store_distances: [
        %{
          store_id: default_store.id,
          store_name: default_store.name,
          distance: distance,
          delivery_available: delivery_available
        }
      ]
    })
    |> Repo.insert()
  end

  def update_distance(%Distance{} = distance, attrs) do
    distance
    |> changeset(attrs)
    |> Repo.update!()
  end

  def delete_distance(%Distance{} = distance) do
    distance |> Repo.delete!()
  end
end
