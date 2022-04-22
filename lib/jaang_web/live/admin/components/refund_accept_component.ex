defmodule JaangWeb.Admin.Components.RefundAcceptComponent do
  use JaangWeb, :live_component
  use Phoenix.HTML
  alias Jaang.Admin.CustomerServices
  alias Jaang.{InvoiceManager, StripeManager}
  alias Jaang.Admin.Order.Orders
  alias Jaang.Admin.Invoice.Invoices
  alias Jaang.Checkout.Calculate

  def update(%{refund_request: refund_request} = assigns, socket) do
    changeset = CustomerServices.change_refund_request(refund_request, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:can_save, changeset.valid?)}
  end

  def render(assigns) do
    ~H"""
     <div class="container mx-auto">
        <p class="text-lg font-medium pb-10"> Do you want to accept this request? </p>

        <.form let={f} for={@changeset} url="#" phx-change="validate" phx-submit="accept" phx-target={@myself}>
          <%= hidden_input f, :invoice_id, value: @refund_request.order.invoice_id %>
          <%= hidden_input f, :order_id, value: @refund_request.order.id %>
          <div class="pb-5">
            <label>Type accept refund total </label>
          </div>
          <div class="pb-5">
            <%= text_input f, :total_accepted_refund, [value: @refund_request.total_requested_refund, phx_debounce: 500] %>
          </div>
          <%= if @changeset.valid? == false do %>
          <div class="pb-5">
            <p class="text-sm font-bold text-red-700"> Please check amount </p>
          </div>
          <% end %>

          <div class="flex">
            <div class="pr-2">
              <button type="button"
                phx-click="close"
                phx-target={@myself}
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
                Cancel
              </button>
            </div>
            <div class="">
              <%= if @changeset.valid? do %>
              <%= submit "Accept",
                 class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              %>

              <% else %>

              <%= submit "Accept",
                 class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-gray-900 bg-gray-100 hover:bg-gray-600 hover:text-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500",
                 disabled: "disabled"
              %>
              <% end %>

            </div>
          </div>
        </.form>
     </div>
    """
  end

  def handle_event(
        "validate",
        %{"refund_request" => %{"total_accepted_refund" => total_accepted_refund}} = _params,
        %{assigns: %{refund_request: refund_request}} = socket
      ) do
    case Money.parse(total_accepted_refund) do
      {:ok, money} ->
        changeset =
          refund_request
          |> CustomerServices.change_refund_request(%{total_accepted_refund: money})
          |> Map.put(:action, :validate)

        socket =
          assign(socket, :changeset, changeset)
          |> assign(:can_save, changeset.valid?)

        {:noreply, socket}

      :error ->
        changeset =
          CustomerServices.add_error_to_customer_services(
            socket.assigns.changeset,
            :total_accepted_refund,
            "Please check amount"
          )

        socket =
          update(socket, :changeset, fn _changeset -> changeset end)
          |> assign(:can_save, changeset.valid?)

        {:noreply, socket}
    end
  end

  def handle_event(
        "accept",
        %{
          "refund_request" => %{
            "total_accepted_refund" => total_accepted_refund,
            "invoice_id" => invoice_id,
            "order_id" => order_id
          }
        },
        %{assigns: %{refund_request: refund_request}} = socket
      ) do
    # get invoice to get payment_intent_id
    invoice = Invoices.get_invoice(invoice_id)

    with {:ok, money} <- Money.parse(total_accepted_refund),
         {:ok, _result} <- StripeManager.create_refund(invoice.pm_intent_id, money.amount),
         {:ok, updated_refund_request} <-
           CustomerServices.update_refund_request(refund_request, %{
             total_accepted_refund: money,
             status: :refunded
           }) do
      # Update invoice grand_total_price and total_items
      # Get order and update sales_tax, total_items, grand_total
      # if previous grand_total == refund_item_total then change status
      # to refunded or else partially refunded

      order = Orders.get_order(order_id)

      status =
        if Money.compare(money, order.grand_total) == 0 do
          :refunded
        else
          :partially_refunded
        end

      grand_total_after_refund = Money.subtract(order.grand_total, money)

      Orders.update_order_and_notify(
        order_id,
        %{grand_total_after_refund: grand_total_after_refund, status: status},
        status
      )

      updated_invoice = Invoices.get_invoice(invoice_id)
      # Update invoice
      grand_total_price =
        Calculate.calculate_grand_final_after_refund_for_invoice(updated_invoice)

      invoice_status = Invoices.build_invoice_status(invoice_id)

      {:ok, invoice} =
        Invoices.update_invoice_and_notify(invoice_id, %{
          grand_total_price: grand_total_price,
          status: invoice_status
        })


      send(self(), {:updated, updated_refund_request})

      socket =
        socket
        |> put_flash(:info, "Refund request accepted and refunded completely")
        |> push_redirect(to: socket.assigns.return_to)

      {:noreply, socket}
    else
      _ ->
        socket =
          socket
          |> put_flash(:error, "Refund request failed. Please try again")
          |> push_redirect(to: socket.assigns.return_to)

        {:noreply, socket}
    end
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
