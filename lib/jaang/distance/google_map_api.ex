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
        distance_in_string = Regex.replace(~r/[a-zA-Z]/, distance_in_mile, "") |> String.trim()

        distance =
          cond do
            String.contains?(distance_in_string, ".") == true ->
              String.to_float(distance_in_string)

            true ->
              String.to_integer(distance_in_string)
          end

        {:ok, distance}

      {:error, reason, message} ->
        {:error, reason, message}
    end
  end
end
