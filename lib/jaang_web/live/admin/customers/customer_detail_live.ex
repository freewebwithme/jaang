defmodule JaangWeb.Admin.Customers.CustomerDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Customer.Customers
  alias JaangWeb.Admin.Components.AddressComponent
  alias Jaang.StoreManager

  def mount(%{"user_id" => user_id}, _session, socket) do
    customer = Customers.get_customer(user_id)
    default_store = StoreManager.get_store(customer.profile.store_id)
    {[default_address], rest_addresses} = return_default_address_and_others(customer.addresses)

    socket =
      assign(socket,
        current_page: "Customer detail",
        customer: customer,
        default_store: default_store,
        default_address: default_address,
        rest_addresses: rest_addresses
      )

    {:ok, socket}
  end

  defp return_default_address_and_others(addresses) when is_list(addresses) do
    if Enum.count(addresses) == 0 do
      {nil, nil}
    else
      default = Enum.filter(addresses, & &1.default)
      rest_addresses = Enum.filter(addresses, &(&1.default == false))
      {default, rest_addresses}
    end
  end
end
