defmodule JaangWeb.Admin.Components.FunctionComponents.OrderTableComponent do
  use Phoenix.Component
  use Phoenix.HTML
  alias JaangWeb.Admin.Helpers
  alias JaangWeb.Router.Helpers, as: Routes

  @moduledoc """
  Order table function component
  """

  def order_table(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="flex justify-between items-center py-7 ">
        <!-- Search form -->
        <form class="flex md:ml-0" phx-submit="search">
          <label for="search_field" class="sr-only">Search</label>
          <div class="relative text-gray-400 focus-within:text-gray-600">
            <div class="absolute inset-y-0 left-5 flex items-center pointer-events-none">
              <!-- Heroicon name: solid/search -->
              <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd" />
              </svg>
            </div>
            <input required name="search-field" id="search_field" class="focus:border-indigo-500 focus:ring-indigo-500 rounded-md block w-full h-full pl-12 pr-3 py-5 border-transparent text-gray-900 placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-0 focus:border-transparent sm:text-sm" placeholder="Search" type="search" name="search">
          </div>
          <div class="flex items-center ml-6 justify-between">
            <label for="search-by">Search by</label>
            <select class="ml-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500" name="search-by">
              <%= options_for_select(@search_by_list, @search_by) %>
            </select>
          </div>
          <div class="flex items-center ml-5">
            <%= submit "Search",
              class: "w-20 items-center px-3.5 py-2.5 border border-transparent text-sm font-medium rounded shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
          </div>
        </form>

        <div class="flex justify-end">
          <div class="">
            <form class="" id="select-by-state" phx-change="select-by-state">
              <select name="by-state">
                <%= options_for_select(@filter_by_list, @filter_by) %>
              </select>
              <label for="by-state">by state</label>
            </form>
          </div>
          <div class="ml-5">
            <form class="" id="select-per-page" phx-change="select-per-page" >
              <select name="per-page">
                <%= options_for_select([5, 10, 15, 20], @options.per_page) %>
              </select>
              <label for="per-page">per page</label>
            </form>
          </div>
        </div>
      </div>

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
                    Delivery time
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Employee
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th scope="col" class="relative px-6 py-3">
                    <span class="sr-only">View</span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">

                <div id="orders" phx-update="prepend">


                  <%= for order <- @orders do %>
                    <tr id={"#{order.id}"}>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="flex items-center">
                          <div class="flex-shrink-0 h-10 w-10">
                            <img class="h-10 w-10 rounded-full" src={"#{order.store_logo}"} alt="">
                          </div>
                          <div class="ml-4">
                            <div class="text-sm font-medium text-gray-900">
                              <%= order.store_name %>
                            </div>
                          </div>
                        </div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900"><%= order.delivery_time %></div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900"><%= Helpers.display_money(order.grand_total) %></div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <%= if Enum.count(order.employees) == 0 do %>
                          <p class="text-sm text-red-600"> Not assigned yet </p>
                        <% else %>
                         <%= for employee <- order.employees do %>
                            <div class="flex items-center">
                              <div class="flex-shrink-0 h-10 w-10">
                                <%= if employee.employee_profile.photo_url == nil do %>
                                  <img class="h-10 w-10 rounded-full" src="https://jaang-la.s3.us-west-1.amazonaws.com/default-avatar.jpg" alt="employee picture" >
                                <% else %>
                                  <img class="h-10 w-10 rounded-full" src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=4&amp;w=256&amp;h=256&amp;q=60" alt="employee picture">
                                <% end %>
                              </div>
                              <div class="ml-4">
                                <div class="text-sm text-gray-900">
                                  <%= employee.employee_profile.first_name %>
                                </div>
                                <div class="text-sm text-gray-500">
                                 <%= Helpers.display_phone_number(employee.employee_profile.phone) %>
                                </div>
                              </div>
                            </div>
                         <% end %>
                        <% end %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                          <%= Helpers.capitalize_text(order.status) %>
                        </span>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <.link navigate={Routes.live_path(@socket, JaangWeb.Admin.Orders.OrderDetailLive, order.id)}
                            class="text-indigo-600 hover:text-indigo-900">View</.link>
                      </td>
                    </tr>
                  <% end %>
                </div>

              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    """
  end
end
