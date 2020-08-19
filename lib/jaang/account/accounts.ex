defmodule Jaang.Account.Accounts do
  alias Jaang.Repo
  alias Jaang.Account.{User, Address, Profile}

  def create_user(attrs) do
    {:ok, user} =
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()

    # add user_id to attrs
    attrs = Map.put(attrs, :user_id, user.id)

    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  def create_address(%User{} = user, attrs) do
    attrs = Map.put(attrs, :user_id, user.id)

    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get_by(User, id: id) |> Repo.preload([:profile, :addresses])
  end
end
