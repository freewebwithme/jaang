defmodule JaangWeb.Admin.OrdersLive do
  use JaangWeb, :dashboard_live_view
  alias Jaang.Admin.Invoice.Invoices

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [unfulfilled_invoices: []]}
  end

  def handle_params(params, _url, socket) do
    IO.puts("Inspecting params")
    IO.inspect(params)
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    by_state = params["filter_by"] || "All"

    paginate_options = %{page: page, per_page: per_page}
    state = String.downcase(by_state) |> String.to_atom()
    filter_by = %{by_state: state}

    invoices = Invoices.get_invoices(paginate: paginate_options, filter_by: filter_by)

    has_next_page = Helpers.has_next_page?(Enum.count(invoices), per_page)

    socket =
      assign(socket,
        has_next_page: has_next_page,
        options: paginate_options,
        invoices: invoices,
        current_page: "Orders",
        filter_by: by_state
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
end
