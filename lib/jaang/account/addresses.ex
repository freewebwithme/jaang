defmodule Jaang.Account.Addresses do
  alias Jaang.Account.Address
  alias Jaang.Repo
  import Ecto.Query

  def create_address(attrs) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
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
    address
    |> Repo.delete!()
  end
end
