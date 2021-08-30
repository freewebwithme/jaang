defmodule JaangWeb.Admin.CustomerServices.RefundLive.Index do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.CustomerServices
  alias JaangWeb.Admin.Helpers
  alias JaangWeb.Admin.Components.FunctionComponents.RefundRequestTableComponent

  def mount(_params, _session, socket) do
    if connected?(socket), do: CustomerServices.subscribe()

    socket = assign(socket, current_page: "Refund Request")
    {:ok, socket, temporary_assigns: [refund_requests: []]}
  end

  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}

    refund_requests =
      CustomerServices.list_refund_request(paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(refund_requests), per_page)

    filter_by_list = [
      "All",
      "Completed",
      "Not_completed"
    ]

    filter_by_default = params["filter_by"] || "All"
    search_by_list = ["Email"]
    search_by_default = "Email"

    IO.puts("Refund request")
    IO.inspect(Enum.count(refund_requests))

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        refund_requests: refund_requests,
        filter_by: filter_by_default,
        filter_by_list: filter_by_list,
        search_by_list: search_by_list,
        search_by: search_by_default
      )

    {:noreply, socket}
  end
end
