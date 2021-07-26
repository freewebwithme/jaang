defmodule JaangWeb.Admin.Components.OrderComponent do
  use JaangWeb, :live_component

  def render(assigns) do
    ~L"""
     <div class="bg-white shadow overflow-hidden sm:rounded-md">
      <ul class="divide-y divide-gray-200">
        <!-- If I do phx-update='prepend', paginate and filter by doesn't work -->
        <div id="orders" phx-update="replace">
          <%= for order <- @orders do %>
            <li class="border-b border-gray-200" id="<%= order.id %>">
                <div class="flex items-center px-4 py-4 sm:px-6">
                  <div class="min-w-0 flex-1 flex items-center">
                    <div class="flex-shrink-0">
                      <img class="h-12 w-12 rounded-full" src="<%= Helpers.display_user_avatar(order.user.profile.photo_url) %>" alt="">
                    </div>

                    <div class="min-w-0 flex-1 px-4 md:grid md:grid-cols-5 md:gap-4">
                      <div>
                        <p class="text-sm font-medium text-indigo-600 truncate"><%= order.user.profile.first_name %></p>
                        <p class="mt-2 flex items-center text-sm text-gray-500">
                          <!-- Heroicon name: solid/mail -->
                          <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                            <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
                            <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
                          </svg>
                          <span class="truncate"><%= order.user.email %></span>
                        </p>
                      </div>
                      <!-- Total -->
                      <div>
                        <div>
                          <p class="text-sm text-gray-500"> Total price </p>
                          <p class="mt-2 items-center text-sm text-indigo-600"><%= order.grand_total %> </p>

                        </div>

                      </div>
                      <div>
                        <div>
                          <p class="text-sm text-gray-500"> Total items </p>
                          <p class="mt-2 items-center text-sm text-indigo-600"><%= order.total_items %> </p>
                        </div>

                      </div>
                      <div class="hidden md:block">
                        <div>
                          <p class="text-sm text-gray-600">
                            Delivery
                          </p>
                          <p class="mt-2 items-center text-sm text-indigo-600"><%= order.delivery_time %></p>
                        </div>
                      </div>

                      <div>
                       <div class="">
                        <p class="text-sm text-gray-600"> Order status </p>
                         <p class="mt-2 px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                          <%= Helpers.capitalize_text(order.status) %>
                         </p>
                       </div>

                      </div>

                    </div>
                  </div>
                  <div class="flex items-center">
                    <!-- Heroicon name: solid/chevron-right -->
                    <%= live_redirect "View", to: Routes.live_path(@socket, JaangWeb.Admin.Orders.OrderDetailLive, order.id),
                        class: "text-sm text-indigo-600 hover:text-indigo-900" %>
                    <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                </div>
            </li>
          <% end %>
        </div>
      </ul>
    </div>
    """
  end
end
