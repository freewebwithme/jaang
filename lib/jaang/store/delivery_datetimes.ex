defmodule Jaang.Store.DeliveryDateTimes do
  alias Jaang.Store.DeliveryDateTime

  @available_hours [
    # "9 am to 11 am",
    # "11 am to 1 pm",
    # "1 pm to 3 pm",
    "3 pm to 5 pm",
    "5 pm to 7 pm",
    "7 pm to 9 pm"
  ]

  @delivery_orders [
    # "9 am to 11 am" : 1,
    # "11 am to 1 pm" : 2,
    # "1 pm to 3 pm" : 3,
    "3 pm to 5 pm": 4,
    "5 pm to 7 pm": 5,
    "7 pm to 9 pm": 6
  ]

  @doc """
  Accept delivery datetime from client as String format
  `5pm to 7pm on Today, Mar 8, 2021` or
  `5pm to 7pm on Mar 8, 2021`
  This function is called when place an order
  Saves delivery order to sort by order
  """
  def parse_delivery_datetime(datetime) do
    [time, date] = String.split(datetime, " on ")
    delivery_order = Keyword.fetch!(@delivery_orders, String.to_atom(time))

    [_day, new_date, new_year] = String.split(date, ", ")
    delivery_date_and_year = new_date <> " " <> new_year
    delivery_date = DateTimeParser.parse_date!(delivery_date_and_year, to_utc: true)

    {delivery_order, delivery_date}
  end

  @doc """
  Return available delivery datetime
  """
  def get_available_delivery_datetime() do
    # Get current local date time
    now = Timex.now("America/Los_Angeles")
    # Check if today is available to delivery.
    # 9 am to 7 pm to take an order
    start_hour =
      Timex.to_datetime(
        {{now.year, now.month, now.day}, {9, 00, 00}},
        "America/Los_Angeles"
      )

    close_hour =
      Timex.to_datetime(
        {{now.year, now.month, now.day}, {19, 00, 00}},
        "America/Los_Angeles"
      )

    case Timex.between?(now, start_hour, close_hour) do
      true ->
        # Delivery available now, filter delivery hours
        IO.puts("Delivery today is available")
        return_available_delivery_datetime(now)

      false ->
        if(Timex.before?(now, start_hour)) do
          # Delivery available now, filter delivery hours
          IO.puts("Delivery today is not available")
          return_available_delivery_datetime(now)
        else
          return_future_delivery_datetime(now)
        end
    end
  end

  ### Return available Delivery DateTime
  ### params: now = Timex.local()

  defp return_available_delivery_datetime(now) do
    delivery_datetimes = return_future_delivery_datetime(now)

    # Filter delivery hours for today.
    # Exclude current time + 2 hours
    if(now.minute > 0) do
      # Add 3 hours
      available_start_hour = Timex.add(now, Timex.Duration.from_hours(3))

      today_delivery_date_time = return_today_delivery_datetime(available_start_hour, now)
      [today_delivery_date_time | delivery_datetimes]
    else
      available_start_hour = Timex.add(now, Timex.Duration.from_hours(2))

      today_delivery_date_time = return_today_delivery_datetime(available_start_hour, now)
      [today_delivery_date_time | delivery_datetimes]
    end
  end

  ### return delivery datetime for today
  ### Filter out delivery time
  ### params: available_start_hour = DateTime
  ### now = Timex.local()

  def return_today_delivery_datetime(available_start_hour, now) do
    # If available_start_hour is even(2, 4, 6, 8, 10 am or pm)
    # make it odd hour(3, 5, 7, 9, 11)
    # Because available hours timelines have odd number hour

    # TODO: Delivery time restriction(start 3 pm). Remove later
    available_start_hour =
      if available_start_hour.hour < 15 do
        # We start delivery from 3 pm.
        Timex.to_datetime(
          {{now.year, now.month, now.day}, {15, 00, 00}},
          "America/Los_Angeles"
        )
      else
        available_start_hour
      end

    {:ok, available_start_hour} =
      if(rem(available_start_hour.hour, 2) == 0) do
        IO.puts("even number")
        IO.inspect(available_start_hour)

        Timex.add(available_start_hour, Timex.Duration.from_hours(1))
        |> Timex.format("{h12} {am}")
      else
        IO.puts("odd number")
        IO.inspect(available_start_hour)
        available_start_hour |> Timex.format("{h12} {am}")
      end

    # Get index
    index =
      if(available_start_hour == "9 pm") do
        Enum.find_index(@available_hours, fn hour ->
          String.ends_with?(hour, available_start_hour)
        end)
      else
        Enum.find_index(@available_hours, fn hour ->
          String.starts_with?(hour, available_start_hour)
        end)
      end

    available_hours = Enum.slice(@available_hours, index, Enum.count(@available_hours))
    {:ok, month} = now |> Timex.format("{Mshort}")
    {:ok, year} = now |> Timex.format("{YYYY}")

    %DeliveryDateTime{
      delivery_day: "Today",
      delivery_date: now.day,
      delivery_month: month,
      delivery_year: year,
      available_hours: available_hours
    }
  end

  ### return delivery datetime including 3 days after

  defp return_future_delivery_datetime(now) do
    for x <- 1..3 do
      next_day = Timex.add(now, Timex.Duration.from_days(x))
      {:ok, month} = next_day |> Timex.format("{Mshort}")
      {:ok, name_of_day} = next_day |> Timex.format("%a", :strftime)
      {:ok, year} = next_day |> Timex.format("{YYYY}")

      %Jaang.Store.DeliveryDateTime{
        # 요일
        delivery_day: name_of_day,
        delivery_date: next_day.day,
        delivery_month: month,
        delivery_year: year,
        available_hours: @available_hours
      }
    end
  end
end
