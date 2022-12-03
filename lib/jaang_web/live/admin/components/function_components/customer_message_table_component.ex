defmodule JaangWeb.Admin.Components.FunctionComponents.CustomerMessageTableComponent do
  use Phoenix.Component
  use Phoenix.HTML

  alias JaangWeb.Router.Helpers, as: Routes
  alias JaangWeb.Admin.Helpers

  def customer_message_table(assigns) do
    ~H"""
    <div class="flex flex-col mt-10">
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
                    User
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Order id
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    date
                  </th>
                  <th scope="col" class="relative px-6 py-3">
                    <span class="sr-only">View</span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">

                <div id="customer-messages" phx-update="prepend">


                  <%= for message <- @customer_messages do %>
                    <tr id={"#{message.id}"}>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900"><%= message.user.email %></div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900"><%= message.order.id %></div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <%= if message.status == :new_request do %>
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                            <%= Helpers.capitalize_text(message.status) %>
                          </span>
                        <% end %>
                        <%= if message.status == :completed do %>
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                            <%= Helpers.capitalize_text(message.status) %>
                          </span>
                        <% end %>
                        <%= if message.status == :in_progress do %>
                          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                            <%= Helpers.capitalize_text(message.status) %>
                          </span>
                        <% end %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm text-gray-900"><%= Helpers.display_datetime(message.inserted_at) %></div>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <.link navigate={Routes.live_path(@socket, JaangWeb.Admin.CustomerServices.CustomerMessageLive.Show, message.id)}
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
