defmodule JaangWeb.Resolvers.ProfileResolver do
  alias Jaang.ProfileManager
  alias Jaang.AccountManager

  def update_address(_, args, _) do
    %{address_id: address_id, user_token: token} = args
    address = ProfileManager.get_address(address_id)
    ProfileManager.update_address(address, args)

    user = AccountManager.get_user_by_session_token(token)
    {:ok, %{user: user, token: token, expired: false}}
  end

  def change_default_address(_, args, _) do
    %{user_token: token, address_id: address_id} = args

    address_id = String.to_integer(address_id)
    user = AccountManager.get_user_by_session_token(token)
    addresses = ProfileManager.get_all_addresses(user.id)

    Enum.map(addresses, fn address ->
      cond do
        address.id == address_id ->
          ProfileManager.update_address(address, %{default: true})

        true ->
          ProfileManager.update_address(address, %{default: false})
      end
    end)

    {:ok, %{user: user, token: token, expired: false}}
  end

  def add_address(_, args, _) do
    %{user_token: token} = args
    user = AccountManager.get_user_by_session_token(token)
    attrs = Map.put(args, :user_id, user.id)

    case ProfileManager.create_address(attrs) do
      {:ok, _address} ->
        {:ok, %{user: user, token: token, expired: false}}

      {:error, _changeset} ->
        {:error, %{user: user, token: token, expired: false}}
    end
  end

  def delete_address(_, args, _) do
    %{user_token: token, address_id: address_id} = args
    user = AccountManager.get_user_by_session_token(token)
    address = ProfileManager.get_address(address_id)

    if(address.user_id == user.id) do
      # Delete address
      ProfileManager.delete_address(address)
    end

    {:ok, %{user: user, token: token, expired: false}}
  end
end
