defmodule JaangWeb.Admin.Components.OrderTableLive do
  use JaangWeb, :live_component

  def mount(_params, _session, socket) do
    page = 1
    per_page = 10
    by_state = "All"
    paginate_options = %{page: page, per_page: per_page}
    #    state = String.downcase(by_state) |> String.to_atom()
    #    filter_by = %{by_state: state}

    socket = assign(socket, options: paginate_options, filter_by: by_state)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
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
                    Driver
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Assigned?
                  </th>
                  <th scope="col" class="relative px-6 py-3">
                    <span class="sr-only">View</span>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for data <- @datas do %>
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="flex items-center">
                        <div class="flex-shrink-0 h-10 w-10">
                          <img class="h-10 w-10 rounded-full" src="https://jaang-la.s3-us-west-1.amazonaws.com/sample-data/store-logos/costco.png" alt="">
                        </div>
                        <div class="ml-4">
                          <div class="text-sm font-medium text-gray-900">
                            Costco
                          </div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900"><%= data.delivery_time %></div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900"><%= Helpers.display_money(data.total) %></div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="flex items-center">
                        <div class="flex-shrink-0 h-10 w-10">
                          <img class="h-10 w-10 rounded-full" src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=4&amp;w=256&amp;h=256&amp;q=60" alt="">
                        </div>
                        <div class="ml-4">
                          <div class="text-sm text-gray-900">
                            Karen
                          </div>
                          <div class="text-sm text-gray-500">
                            (213)234-5334
                          </div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                        <%= Helpers.capitalize_text(data.status) %>
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                        Yes
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <%= live_redirect "View", to: Routes.live_path(@socket, JaangWeb.Admin.Orders.OrderDetailLive, data.id),
                          class: "text-indigo-600 hover:text-indigo-900" %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>

            <!-- Pagination button -->
            <div class="bg-white px-4 py-3 xm:px-6">
              <nav class="border-t border-gray-200 px-4 flex items-center justify-between sm:px-0">
                <%= if @options.page > 1 do %>
                  <div class="-mt-px w-0 flex-1 flex">
                   <%= live_patch to: Routes.live_path(
                          @socket,
                          __MODULE__,
                          page: @options.page - 1,
                          per_page: @options.per_page
                        ),
                        class: "border-t-2 border-transparent pt-4 pr-1 inline-flex items-center text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300" do %>
                      <svg class="mr-3 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                        <path fill-rule="evenodd" d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z" clip-rule="evenodd" />
                      </svg>
                      Previous

                    <% end %>
                  </div>
                <% else %>
                  <div class="flex-1 flex"></div>
                <% end %>
                <div class="hidden md:-mt-px md:flex">
                  <%= for i <- (@options.page - 2)..(@options.page + 2), i > 0 do %>
                    <%= if @has_next_page do %>
                      <%= live_patch i, to: Routes.live_path(
                          @socket,
                          __MODULE__,
                          page: i,
                          per_page: @options.per_page
                      ),
                      class: (if i == @options.page, do: "border-indigo-500 text-gray-500 hover:text-gray-700 hover:border-gray-300 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium",
                      else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 border-t-2 pt-4 px-4 inline-flex items-center text-sm font-medium")  %>
                    <% end %>
                  <% end %>
                </div>
                <%= if @has_next_page do %>

                <!-- Next Button -->
                <div class="-mt-px w-0 flex-1 flex justify-end">
                  <%= live_patch to: Routes.live_path(
                            @socket,
                            __MODULE__,
                            page: @options.page + 1,
                            per_page: @options.per_page
                          ),
                         class: "border-t-2 border-transparent pt-4 pl-1 inline-flex items-center text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300" do %>
                    Next
                    <!-- Heroicon name: arrow-narrow-right -->
                    <svg class="ml-3 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
                    </svg>

                  <% end %>
                </div>
                <% end %>
              </nav>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
