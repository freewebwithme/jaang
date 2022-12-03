defmodule JaangWeb.StoreChannel do
  use Phoenix.Channel
  alias Jaang.Admin.Invoice.Invoices
  alias Jaang.Admin.Order.Orders
  alias Jaang.Admin.EmployeeTask.EmployeeTasks
  alias Jaang.Admin.EmployeeTask
  alias Jaang.Amazon.S3

  intercept ["order_updated", "new_order"]

  @impl true
  def join("store:" <> store_id, _params, %{assigns: %{current_employee: employee}} = socket) do
    # Check if current employee is employee of current store
    if employee_belongs_to_store?(employee, store_id) do
      IO.puts("Joining store channel: #{store_id}")
      socket = assign(socket, store_id: store_id)
      # grouped_invoices = Invoices.get_unfulfilled_invoices(store_id)

      # {:ok,
      # %{
      #   submitted: grouped_invoices.submitted,
      #   packed: grouped_invoices.packed,
      #   on_the_way: grouped_invoices.on_the_way
      # }, socket}
      {:ok, socket}
    else
      {:error, %{reason: "unauthenticated"}}
    end
  end

  def join("store:" <> _store_id, _params, _socket) do
    IO.puts("Can't join a chnannel")
    {:error, %{reason: "unauthenticated"}}
  end

  @impl true
  def handle_in(
        "get_order_info",
        _payload,
        %{assigns: %{store_id: store_id, current_employee: employee}} = socket
      ) do
    IO.puts("Incoming event from client: 'get_order_info'")
    IO.puts("Printing employee id #{employee.id}")

    case return_grouped_orders(store_id, employee.id) do
      {:ok, %{submitted: submitted, shopping: shopping, packed: packed, on_the_way: on_the_way}} ->
        {:reply,
         {:ok,
          %{
            submitted: submitted,
            shopping: shopping,
            packed: packed,
            on_the_way: on_the_way
          }}, socket}

      {:empty, %{}} ->
        {:reply, {:ok, %{has_data: false}}, socket}
    end
  end

  # This handle_in function to check if employee has in-progress task that must finish
  @impl true
  def handle_in("check_employee_task", %{"employee_id" => employee_id} = _payload, socket) do
    IO.puts("Incoming event from client: 'check_employee_task'")

    case EmployeeTasks.get_in_progress_employee_task(employee_id) do
      nil ->
        {:reply, {:ok, %{has_in_progress_task: false}}, socket}

      employee_task ->
        # get invoice and return with employee_task
        order = Orders.get_order(employee_task.order_id)

        # Group by line items' status
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        {:reply,
         {:ok,
          %{
            has_in_progress_task: true,
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}
    end
  end

  @impl true
  def handle_in("start_shopping", payload, %{assigns: %{store_id: store_id}} = socket) do
    IO.puts("Calling handle_in('start_shopping')")
    %{"order_id" => order_id, "employee_id" => employee_id} = payload

    # Check if employee has currently working invoice.
    store_id = String.to_integer(store_id)

    case EmployeeTasks.get_in_progress_employee_task(employee_id) do
      nil ->
        {:ok, order} = Orders.assign_employee_to_order(order_id, employee_id, :shopping, store_id)

        IO.puts("Creating employee task...")
        # Create employee task
        {:ok, employee_task} =
          EmployeeTasks.create_employee_task(
            order_id,
            employee_id,
            "shopping",
            "in_progress"
          )

        # Group by line items' status
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      employee_task = %EmployeeTask{} ->
        # Employee has currently working tasks return existing employee task
        # Get order
        order = Orders.get_order(employee_task.order_id)

        # Group by line items' status
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}
    end
  end

  @impl true
  def handle_in(
        "continue_shopping",
        %{"order_id" => order_id, "employee_id" => employee_id} = _payload,
        socket
      ) do
    IO.puts("Calling handle_in(`continue_shopping')")
    employee_task = EmployeeTasks.get_in_progress_employee_task(employee_id)
    # Group by line items' status
    %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
      group_by_line_item_status(employee_task)

    order = Orders.get_order(order_id)
    # Send reply with updated invoice
    {:reply,
     {:ok,
      %{
        employee_task: employee_task,
        order: order,
        ready: ready,
        not_ready: not_ready,
        sold_out: sold_out
      }}, socket}
  end

  @impl true
  def handle_in(
        "update_line_item",
        %{
          "employee_id" => employee_id,
          "line_item_id" => line_item_id,
          "status" => status,
          "refund_reason" => refund_reason
        },
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item`")

    case EmployeeTasks.update_employee_task_line_item_status(
           employee_id,
           line_item_id,
           status,
           refund_reason
         ) do
      {:ok, employee_task} ->
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        order = Orders.get_order(employee_task.order_id)
        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in(
        "update_line_item_with_replacement_for_barcode_product",
        %{
          "employee_id" => employee_id,
          "line_item_id" => line_item_id,
          "status" => status,
          "replacement_item_id" => replacement_item_id
        },
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item_with_replacement_for_barcode_product`)")
    {:ok, socket}

    case EmployeeTasks.update_employee_task_replacement_for_barcode_product(
           employee_id,
           line_item_id,
           replacement_item_id,
           status
         ) do
      {:ok, employee_task} ->
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        order = Orders.get_order(employee_task.order_id)
        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      {:error, message} ->
        {:reply, {:error, message}, socket}
    end
  end

  @impl true
  def handle_in(
        "update_line_item_quantity_or_weight",
        %{"employee_id" => employee_id, "line_item_id" => line_item_id, "quantity" => quantity},
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item_quantity_or_weight`)")

    case EmployeeTasks.update_quantity_or_weight_for_line_item(
           :quantity,
           employee_id,
           line_item_id,
           quantity
         ) do
      {:ok, employee_task} ->
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        order = Orders.get_order(employee_task.order_id)
        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      {:error, message} ->
        {:reply, {:error, message}, socket}
    end
  end

  @impl true
  def handle_in(
        "update_line_item_quantity_or_weight",
        %{"employee_id" => employee_id, "line_item_id" => line_item_id, "weight" => weight},
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item_quantity_or_weight`)")

    case EmployeeTasks.update_quantity_or_weight_for_line_item(
           :weight,
           employee_id,
           line_item_id,
           weight
         ) do
      {:ok, employee_task} ->
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        order = Orders.get_order(employee_task.order_id)
        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      {:error, message} ->
        IO.puts("Updating line_item weight error")
        {:reply, {:error, message}, socket}
    end
  end

  # Update replacement item
  @impl true
  def handle_in(
        "update_line_item_with_replacement",
        %{
          "employee_id" => employee_id,
          "line_item_id" => line_item_id,
          "quantity" => quantity,
          "replacement_line_item_id" => replacement_line_item_id
        },
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item_with_replacement`)")

    case EmployeeTasks.update_line_item_with_replacement_for_no_barcode(
           :quantity,
           employee_id,
           line_item_id,
           replacement_line_item_id,
           quantity
         ) do
      {:ok, employee_task} ->
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        order = Orders.get_order(employee_task.order_id)
        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      {:error, message} ->
        {:reply, {:error, message}, socket}
    end
  end

  @impl true
  def handle_in(
        "update_line_item_with_replacement",
        %{
          "employee_id" => employee_id,
          "line_item_id" => line_item_id,
          "weight" => weight,
          "replacement_line_item_id" => replacement_line_item_id
        },
        socket
      ) do
    IO.puts("Calling handle_in(`update_line_item_with_replacement`)")

    case EmployeeTasks.update_line_item_with_replacement_for_no_barcode(
           :weight,
           employee_id,
           line_item_id,
           replacement_line_item_id,
           weight
         ) do
      {:ok, employee_task} ->
        %{ready: ready, not_ready: not_ready, sold_out: sold_out} =
          group_by_line_item_status(employee_task)

        # invoice = Invoices.get_invoice(employee_task.invoice_id)
        order = Orders.get_order(employee_task.order_id)
        # Send reply with updated invoice
        {:reply,
         {:ok,
          %{
            employee_task: employee_task,
            order: order,
            ready: ready,
            not_ready: not_ready,
            sold_out: sold_out
          }}, socket}

      {:error, message} ->
        {:reply, {:error, message}, socket}
    end
  end

  @impl true
  def handle_in("request_presigned_url", %{"file_names" => file_names}, socket) do
    IO.puts("handle_in('request_presigned_url')")

    presigned_urls =
      Enum.map(file_names, fn file_name ->
        {:ok, url} = S3.create_presigned_url(:put, file_name, "receipts")
        url
      end)

    {:reply, {:ok, presigned_urls}, socket}
  end

  @impl true
  def handle_in("receipt_photo_urls", %{"urls" => urls, "order_id" => order_id}, socket) do
    IO.puts("handle_in('receipt_photo_url')")

    case Orders.update_order_with_receipt_photos(order_id, urls) do
      {:ok, order} ->
        {:reply, {:ok, %{order: order}}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  @doc """
  Finalize order from Worker app.
  """
  @impl true
  def handle_in(
        "finalize_order",
        %{
          "order_id" => order_id,
          "number_of_bags" => numb_bags,
          "employee_id" => employee_id,
          "employee_task_id" => employee_task_id
        },
        socket
      ) do
    IO.puts("handle_in('finalize_order')")
    {numb_bags, ""} = Integer.parse(numb_bags)
    employee_task = EmployeeTasks.get_employee_task_by_id(employee_task_id)

    with {:ok, order} <- Orders.finalize_order(order_id, employee_task_id, numb_bags),
         {:ok, _employee_task} <-
           EmployeeTasks.update_employee_task(employee_task, %{
             task_status: :done,
             end_datetime: Timex.now(),
             duration: Timex.diff(Timex.now(), employee_task.start_datetime, :minutes)
           }),
         {:ok, _invoice} <- Invoices.finalize_invoice(order) do
      IO.puts("Finalized order successful")
      # Get packed invoice for employee
      packed_orders = Orders.count_packed_order_for_employee(employee_id)
      {:reply, {:ok, %{packed_orders_count: packed_orders}}, socket}
    else
      {:error, _error} ->
        IO.puts("Finalized order failure")
        {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in(
        "update_order_status",
        %{"order_id" => order_id, "status" => status},
        socket
      ) do
    IO.puts("handle_in('update_order_status')")
    status = String.to_atom(status)

    with {:ok, _order} <-
           Orders.update_order_and_notify(order_id, %{status: status}, status) do
      {:reply, :ok, socket}
    else
      :error ->
        {:reply, :error, socket}
    end
  end

  @impl true
  def handle_in(
        "finish_order_delivery",
        %{"order_id" => order_id, "delivery_method" => delivery_method},
        socket
      ) do
    IO.puts("handle_in('finish_order_delivery')")

    with {:ok, order} <-
           Orders.update_order_and_notify(
             order_id,
             %{delivery_method: delivery_method, status: :delivered},
             :delivered
           ) do
      invoice_status = Invoices.build_invoice_status(order.invoice_id)
      Invoices.update_invoice_and_notify(order.invoice_id, %{status: invoice_status})
      {:reply, :ok, socket}
    else
      :error ->
        {:reply, :error, socket}
    end
  end

  @impl true
  @doc """
  Whenever order is updated, send updated order and updated order list
  using handle_in
  """
  def handle_out(
        "order_updated",
        _message,
        %{assigns: %{store_id: store_id, current_employee: employee}} = socket
      ) do
    IO.puts("Order updated handle out: ")

    case return_grouped_orders(store_id, employee.id) do
      {:ok, %{submitted: submitted, shopping: shopping, packed: packed, on_the_way: on_the_way}} ->
        push(socket, "order_updated", %{
          submitted: submitted,
          shopping: shopping,
          packed: packed,
          on_the_way: on_the_way
        })

        {:noreply, socket}

      {:empty, %{}} ->
        push(socket, "order_updated", %{has_data: false})
        {:noreply, socket}
    end
  end

  def handle_out(
        "new_order",
        _message,
        %{assigns: %{store_id: store_id, current_employee: employee}} = socket
      ) do
    IO.puts("new order handle out(store_id): #{store_id}")

    case return_grouped_orders(store_id, employee.id) do
      {:ok, %{submitted: submitted, shopping: shopping, packed: packed, on_the_way: on_the_way}} ->
        push(socket, "new_order", %{
          # invoice: invoice,
          submitted: submitted,
          shopping: shopping,
          packed: packed,
          on_the_way: on_the_way
        })

        {:noreply, socket}

      {:empty, %{}} ->
        push(socket, "new_order", %{has_data: false})
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp return_grouped_orders(store_id, employee_id) do
    grouped_orders = Orders.get_unfulfilled_orders(store_id)

    if grouped_orders == %{} do
      {:empty, %{}}
    else
      # Filter each order by employee id
      shopping_orders =
        filter_orders_by_employee_id_and_status(
          grouped_orders,
          :shopping,
          employee_id,
          store_id
        )

      packed_orders =
        filter_orders_by_employee_id_and_status(
          grouped_orders,
          :packed,
          employee_id,
          store_id
        )

      ontheway_orders =
        filter_orders_by_employee_id_and_status(
          grouped_orders,
          :on_the_way,
          employee_id,
          store_id
        )

      {:ok,
       %{
         submitted: Map.get(grouped_orders, :submitted) || [],
         shopping: shopping_orders,
         packed: packed_orders,
         on_the_way: ontheway_orders
       }}
    end
  end

  defp filter_orders_by_employee_id_and_status(orders, order_status, employee_id, store_id) do
    # Check if orders list has key(:shopping, :packed, :on_the_way)
    # if no key exist, just return empty list
    store_id = String.to_integer(store_id)

    orders =
      if Map.has_key?(orders, order_status) do
        Map.get(orders, order_status)
        |> Enum.filter(fn order ->
          Enum.any?(order.employees, fn employee -> employee.id == employee_id end)
        end)
      else
        []
      end

    orders
    |> Enum.filter(&(&1.store_id == store_id))
  end

  defp employee_belongs_to_store?(employee, store_id) do
    store_id = String.to_integer(store_id)

    stores =
      Enum.filter(employee.assigned_stores, fn store ->
        store.id == store_id
      end)

    result =
      case Enum.count(stores) > 0 do
        true -> true
        _ -> false
      end

    result
  end

  defp group_by_line_item_status(%EmployeeTask{} = employee_task) do
    {ready, not_ready, sold_out} =
      Enum.group_by(employee_task.line_items, & &1.status)
      |> group_by_category_name()

    %{
      ready: ready,
      not_ready: not_ready,
      sold_out: sold_out
    }
  end

  defp group_by_category_name(grouped_line_items) do
    ready_line_items = Map.get(grouped_line_items, :ready)
    not_ready_line_items = Map.get(grouped_line_items, :not_ready)
    sold_out_line_items = Map.get(grouped_line_items, :sold_out)

    ready_line_items =
      if ready_line_items do
        Enum.group_by(ready_line_items, & &1.category_name)
      else
        %{}
      end

    not_ready_line_items =
      if not_ready_line_items do
        Enum.group_by(not_ready_line_items, & &1.category_name)
      else
        %{}
      end

    sold_out_line_items =
      if sold_out_line_items do
        Enum.group_by(sold_out_line_items, & &1.category_name)
      else
        %{}
      end

    {ready_line_items, not_ready_line_items, sold_out_line_items}
  end
end
