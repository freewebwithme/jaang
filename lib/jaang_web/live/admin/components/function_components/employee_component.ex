defmodule JaangWeb.Admin.Components.FunctionComponents.EmployeeComponent do
  use Phoenix.Component
  use Phoenix.HTML

  alias JaangWeb.Admin.Helpers
  alias JaangWeb.Admin.Employees.EmployeesOverviewLive
  alias JaangWeb.Router.Helpers, as: Routes

  def employee_component(assigns) do
    ~H"""
    <div class="bg-white shadow overflow-hidden rounded-md">
      <ul class="divide-y divide-gray-200">
        <%= for employee <- @employees  do %>
        <li class="px-y py-4 border-b border-gray-200">
          <div class="flex items-center px-4 py-4 sm:px-6">
            <div class="min-w-0 flex-1 flex items-center">
              <div class="flex-shrink-0">
                <img class="h-12 w-12 rounded-full" src={Helpers.display_user_avatar(nil)} alt="">
              </div>
              <div class="min-w-0 flex-1 px-4 md:grid md:grid-cols-5 md:gap-4">
                <div>
                  <p class="text-sm font-medium text-indigo-600 truncate"><%= employee.employee_profile.first_name %></p>
                  <p class="mt-2 flex items-center text-sm text-gray-500">
                    <!-- Heroicon name: solid/mail -->
                    <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
                      <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
                    </svg>
                    <span class="truncate"><%= employee.email %></span>
                  </p>
                </div>
                <!-- Total -->
                <div>
                  <div>
                    <p class="text-sm text-gray-500">Phone</p>
                    <p class="mt-2 items-center text-sm text-indigo-600"><%= Helpers.display_phone_number(employee.employee_profile.phone)%></p>

                  </div>

                </div>
                <div>
                  <div>
                    <p class="text-sm text-gray-500"> Roles </p>
                    <p class="mt-2 items-center text-sm text-indigo-600"><%= EmployeesOverviewLive.display_roles(employee.roles) %></p>
                  </div>

                </div>
                <div>
                  <div>
                    <p class="text-sm text-gray-500"> Assigned Stores</p>
                    <p class="mt-2 items-center text-sm text-indigo-600">
                      <%= EmployeesOverviewLive.display_roles(employee.assigned_stores) %>
                    </p>
                  </div>

                </div>
                <div>
                 <div class="">
                  <p class="text-sm text-gray-600"> Active </p>
                    <%= if employee.active do %>
                      <p class="mt-2 px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                       <%= employee.active %>
                      </p>
                    <% else %>
                      <p class="mt-2 px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                       <%= employee.active %>
                      </p>
                    <% end %>
                 </div>
                </div>
              </div>
            </div>
            <div class="flex items-center">
              <!-- Heroicon name: solid/chevron-right -->
              <%= live_redirect "View", to: Routes.live_path(@socket, JaangWeb.Admin.Employees.EmployeeDetailLive, employee.id),
                  class: "text-sm text-indigo-600 hover:text-indigo-900" %>
              <svg class="h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
        </li>
        <% end %>
      </ul>
    </div>

    """
  end
end
