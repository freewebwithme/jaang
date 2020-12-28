defmodule Jaang.Utility do
  @doc """
  convert and format datetime
  param: ~N , naive datetime
  returns: {:ok, "Nov 19, 2020 5:07PM"}
  """
  def convert_and_format_datetime(datetime) do
    Timex.local(datetime)
    |> Timex.format("{Mshort} {D}, {YYYY} {h12}:{m}{AM}")
  end
end