defmodule JaangWeb.Admin.Customers.CustomerDetailLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Customer.Customers
  alias JaangWeb.Admin.Components.{AddressComponent}
  alias JaangWeb.Admin.Components.FunctionComponents.InvoiceTableComponent
  alias Jaang.Admin.Invoice.Invoices
  alias Jaang.StoreManager

  def mount(%{"user_id" => user_id}, _session, socket) do
    customer = Customers.get_customer(user_id)
    default_store = get_default_store(customer.profile.store_id)
    {[default_address], rest_addresses} = return_default_address_and_others(customer.addresses)

    socket =
      assign(socket,
        user_id: user_id,
        current_page: "Customer detail",
        customer: customer,
        default_store: default_store,
        default_address: default_address,
        rest_addresses: rest_addresses
      )

    {:ok, socket, temporary_assigns: [orders: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}

    user_by = %{user_id: socket.assigns.user_id}

    invoices =
      Invoices.get_invoices(user_by: user_by, paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(invoices), per_page)

    filter_by_list = [
      "All",
      "Cart",
      "Refunded",
      "Submitted",
      "Shopping",
      "Packed",
      "On_the_way",
      "Delivered"
    ]

    filter_by_default = "ALL"

    search_by_list = ["Invoice id"]
    search_by_default = "Invoice id"

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        invoices: invoices,
        filter_by: filter_by_default,
        filter_by_list: filter_by_list,
        search_by_list: search_by_list,
        search_by: search_by_default
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    has_next_page = Helpers.has_next_page?(Enum.count(socket.assigns.invoices), per_page)

    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            has_next_page: has_next_page
          )
      )

    {:noreply, socket}
  end

  def handle_event("select-by-state", %{"by-state" => by_state}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: socket.assigns.options.per_page,
            has_next_page: socket.assigns.has_next_page,
            filter_by: by_state
          )
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"search-by" => search_by, "search-field" => search_term}, socket) do
    socket =
      push_navigate(
        socket,
        to:
          Routes.live_path(
            socket,
            OrderSearchResultLive,
            search_by: search_by,
            search_term: search_term
          )
      )

    {:noreply, socket}
  end

  defp return_default_address_and_others(addresses) when is_list(addresses) do
    if Enum.count(addresses) == 0 do
      {[nil], nil}
    else
      default = Enum.filter(addresses, & &1.default)
      rest_addresses = Enum.filter(addresses, &(&1.default == false))
      {default, rest_addresses}
    end
  end

  defp get_default_store(store_id) when is_nil(store_id), do: nil

  defp get_default_store(store_id) do
    StoreManager.get_store(store_id)
  end
end
