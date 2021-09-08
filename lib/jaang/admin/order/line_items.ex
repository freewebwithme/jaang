defmodule Jaang.Admin.Order.LineItems do
  @doc """
  Collect line_item_id from maps
  """
  @spec get_ids_from_refund_items_map(list(map)) :: list(:binary)
  def get_ids_from_refund_items_map(refund_items_maps) do
    Enum.map(refund_items_maps, & &1.line_item_id)
  end

  @doc """
  Accept order and list of line_item_id as param
  And filter the line_item by ids and
  if replaced == true, check replacement_item.id also
  """
  def filter_line_item_by_ids(order, ids) do
    Enum.filter(order.line_items, fn item ->
      if(item.replaced) do
        item.replacement_item.id in ids
      else
        item.id in ids
      end
    end)
  end

  @doc """
  Convert LineItem struct to map including replacement_item
  """
  @spec convert_line_item_to_map(list(LineItem)) :: list(map)
  def convert_line_item_to_map(line_items) do
    Enum.map(line_items, fn line_item ->
      if(line_item.has_replacement) do
        line_item_map = Map.from_struct(line_item)
        # convert replacement_item also
        replacement_item_map = Map.from_struct(line_item.replacement_item)
        Map.put(line_item_map, :replacement_item, replacement_item_map)
      else
        Map.from_struct(line_item)
      end
    end)
  end

  @spec update_line_item_maps(list(map), list(map)) :: list(map)
  def update_line_item_maps(line_item_maps, new_value_maps) do
    Enum.map(line_item_maps, fn line_item_map ->
      case line_item_map.replaced do
        true ->
          # get new_value using line_item.id
          [new_value_map] =
            Enum.filter(new_value_maps, &(&1.line_item_id == line_item_map.replacement_item.id))

          # Check if line_item is weight based
          if(line_item_map.replacement_item.weight_based) do
            # update line_item_map using new value
            Map.update!(line_item_map.replacement_item, :weight, fn _old ->
              new_value_map.weight
            end)
            |> Map.update!(:refund_reason, fn _old -> new_value_map.refund_reason end)
          else
            # update line_item_map using new value
            Map.update!(line_item_map.replacement_item, :quantity, fn _old ->
              new_value_map.quantity
            end)
            |> Map.update!(:refund_reason, fn _old -> new_value_map.refund_reason end)
          end

        _ ->
          # get new_value using line_item.id
          [new_value_map] = Enum.filter(new_value_maps, &(&1.line_item_id == line_item_map.id))

          if(line_item_map.weight_based) do
            # update line_item_map using new value
            Map.update!(line_item_map, :weight, fn _old -> new_value_map.weight end)
            |> Map.update!(:refund_reason, fn _old -> new_value_map.refund_reason end)
          else
            # update line_item_map using new value
            Map.update!(line_item_map, :quantity, fn _old -> new_value_map.quantity end)
            |> Map.update!(:refund_reason, fn _old -> new_value_map.refund_reason end)
          end
      end
    end)
  end
end
