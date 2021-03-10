defmodule Jaang.Utility do
  @doc """
  convert and format datetime
  param: ~N , naive datetime
  returns: {:ok, "Nov 19, 2020 5:07 PM"}
  """
  def convert_and_format_datetime(datetime) do
    Timex.to_datetime(datetime, "America/Los_Angeles")
    |> Timex.format("{Mshort} {D}, {YYYY} {h12}:{m} {AM}")
  end

  @doc """
  Convert string key to atom key in map
  """
  def convert_string_key_to_atom_key(attrs) do
    for {key, value} <- attrs, into: %{}, do: {String.to_atom(key), value}
  end

  @doc """
  Price compare
  params:
  old_price = %MarketPrice{}
  new_price = %Money{}
  """
  def price_changed?(old_price, new_price) do
    price_changed =
      cond do
        old_price.on_sale == true ->
          if Money.compare(new_price, old_price.sale_price) == 0 do
            false
          else
            true
          end

        old_price.on_sale == false ->
          if Money.compare(new_price, old_price.original_price) == 0 do
            false
          else
            true
          end

        true ->
          false
      end

    price_changed
  end

  @doc """
  Check if date is today.
  This function is called for checking invoice.delivery_date is Today
  """
  def today?(date) do
    Timex.today() == date
  end
end
