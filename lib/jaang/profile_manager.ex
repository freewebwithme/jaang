defmodule Jaang.ProfileManager do
  alias Jaang.Account.Addresses

  # Addresses

  defdelegate create_address(attrs), to: Addresses
  defdelegate get_address(id), to: Addresses
  defdelegate get_all_addresses(user_id), to: Addresses
  defdelegate update_address(address, attrs), to: Addresses
  defdelegate delete_address(address), to: Addresses
end
