defmodule Jaang.Account.Addresses do
  alias Jaang.Account.Address
  alias Jaang.Repo

  def create_address(attrs) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
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
