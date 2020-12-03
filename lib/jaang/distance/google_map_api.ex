defmodule Jaang.Distance.GoogleMapApi do
  alias GoogleMaps

  def calculate_distance(from, to) do
    case GoogleMaps.distance(from, to, units: "imperial") do
      {:ok,
       %{
         "rows" => [
           %{
             "elements" => [
               %{"distance" => %{"text" => distance_in_mile, "value" => _distance_in_meter}}
             ]
           }
         ]
       }} ->
        distance_in_float =
          Regex.replace(~r/[a-zA-Z]/, distance_in_mile, "") |> String.trim() |> String.to_float()

        {:ok, distance_in_float}

      {:error, message} ->
        {:error, message}
    end
  end
end
