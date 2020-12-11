defmodule Jaang.ProfileManager do
  alias Jaang.Account.Addresses

  # Addresses

  defdelegate create_address(attrs), to: Addresses
  defdelegate get_address(id), to: Addresses
  defdelegate get_default_address(addresses), to: Addresses
  defdelegate get_all_addresses(user_id), to: Addresses
  defdelegate update_address(address, attrs), to: Addresses
  defdelegate delete_address(address), to: Addresses
  defdelegate build_address(addresss), to: Addresses

  @doc """
  Change default address for user
  change default: false for other address
  """
  defdelegate change_default_address(user, address_id), to: Addresses
end
