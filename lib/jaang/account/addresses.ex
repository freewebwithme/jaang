defmodule Jaang.Account.Addresses do
  alias Jaang.Account.Address
  alias Jaang.Repo
  alias Jaang.Distance
  alias Jaang.AccountManager
  alias Ecto.Changeset

  import Ecto.Query

  def create_address(attrs) do
    user_id = Map.get(attrs, :user_id)
    addresses = get_all_addresses(user_id)

    cond do
      Enum.count(addresses) == 0 ->
        # There is no address, This will be first and default address.
        attrs = Map.put(attrs, :default, true)

        {:ok, address} =
          %Address{}
          |> Address.changeset(attrs)
          |> Repo.insert()

        # Create new distance information
        Distance.create_distance(user_id, address)

      true ->
        {:ok, address} =
          %Address{}
          |> Address.changeset(attrs)
          |> Repo.insert()

        # Create new distance information
        Distance.create_distance(user_id, address)
    end
  end

  def get_default_address(addresses) do
    Enum.find(addresses, &(&1.default == true))
  end

  def get_address(id) do
    Repo.get_by(Address, id: id) |> Repo.preload([:distance])
  end

  def get_all_addresses(user_id) do
    Repo.all(from addr in Address, where: addr.user_id == ^user_id, preload: :distance)
  end

  @doc """
  Updating an address
  Check if new updated address is available to deliver
  """
  def update_address(%Address{} = address, attrs) do
    address_changeset = Address.changeset(address, attrs)
    # user is change default address?
    change_default_address = Changeset.get_change(address_changeset, :default)

    cond do
      change_default_address == nil ->
        # user is not changing default address
        new_address = address_changeset |> Repo.update!()

        # If user update an address, delete distance information and make new one
        new_address = get_address(new_address.id)

        if(new_address.distance == nil) do
          # There is no distance information(schema) so create one
          Distance.create_distance(new_address.user_id, new_address)
        else
          # There is a distance schema, so delete and make new one
          Distance.delete_distance(new_address.distance)
          # Create a new one
          Distance.create_distance(new_address.user_id, new_address)
        end

        new_address

      true ->
        # User is changing default address
        IO.puts("Inspecting address changeset")
        IO.inspect(address_changeset)
        new_address = address_changeset |> Repo.update!()
        # Get user and store id to check and update store distance
        user = AccountManager.get_user(new_address.user_id)
        Distance.check_and_update_store_distance(user, user.profile.store_id)
        new_address
    end
  end

  def delete_address(%Address{} = address) do
    cond do
      address.default == true ->
        {:error, "can't delete default address"}

      true ->
        address
        |> Repo.delete!()
    end
  end

  @doc """
  Build an address as string format
  to be used for calculate distance between store and user's address
  """
  def build_address(address) do
    "#{address.address_line_one} #{address.address_line_two} #{address.city}, #{address.state} #{
      address.zipcode
    }"
  end
end
