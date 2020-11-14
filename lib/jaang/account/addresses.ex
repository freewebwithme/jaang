defmodule Jaang.Account.Addresses do
  alias Jaang.Account.Address
  alias Jaang.Repo
  import Ecto.Query

  def create_address(attrs) do
    user_id = Map.get(attrs, :user_id)
    addresses = get_all_addresses(user_id)

    cond do
      Enum.count(addresses) == 0 ->
        # There is no address, This will be first and default address.
        attrs = Map.put(attrs, :default, true)

        %Address{}
        |> Address.changeset(attrs)
        |> Repo.insert()

      true ->
        %Address{}
        |> Address.changeset(attrs)
        |> Repo.insert()
    end
  end

  def get_address(id) do
    Repo.get_by(Address, id: id)
  end

  def get_all_addresses(user_id) do
    Repo.all(from addr in Address, where: addr.user_id == ^user_id)
  end

  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update!()
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
end
