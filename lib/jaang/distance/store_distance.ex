defmodule Jaang.Distance.StoreDistance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Jaang.Distance.{StoreDistance, GoogleMapApi}

  embedded_schema do
    field :store_name, :string
    field :store_id, :id
    field :distance, :float
    field :delivery_available, :boolean
  end

  @doc false
  def changeset(%StoreDistance{} = store_distance, attrs) do
    IO.puts("Inspecting attrs from StoreDistance changeset")
    IO.inspect(attrs)

    store_distance
    |> cast(attrs, [:store_id, :store_name, :distance, :delivery_available])
    |> validate_required([:store_id, :store_name, :distance, :delivery_available])
  end

  def delivery_available?(store_address, user_address) do
    case GoogleMapApi.calculate_distance(store_address, user_address) do
      {:ok, distance} ->
        if(distance > 2.0) do
          {distance, false}
        else
          {distance, true}
        end

      {:error, _message} ->
        {nil, false}
    end
  end
end
