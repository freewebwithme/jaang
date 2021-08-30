defmodule JaangWeb.Admin.Components.AddressComponent do
  use JaangWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-white px-4 py-5 shadow sm:rounded-lg sm:px-4">
      <h2 id="timeline-title" class="text-lg font-medium text-gray-900 mb-4"><%= @title %></h2>
      <%= if @address == nil do %>
        <p>There is no registered address.</p>
      <% else %>
      <div class="border-t border-gray-200 py-5">
        <p class="text-sm py-2"><%= @address.address_line_one %> <%= @address.address_line_two %></p>
        <p class="text-sm py-2"><%= @address.city %> <%= @address.state %> <%= @address.zipcode %></p>
      </div>
      <!-- Store distance table -->
      <div class="flex flex-col">
        <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
            <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Store
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Distance
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Delivery Available
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <%= for store_distance <- @address.distance.store_distances  do %>
                    <!-- Odd row -->
                    <tr class="bg-white">
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        <%= store_distance.store_name %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <%= store_distance.distance %> miles
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <%= if store_distance.delivery_available do %>
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                            Yes
                          </span>
                        <% else %>
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                            No
                          </span>

                        <% end %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      <% end %>
    </div>
    """
  end
end
