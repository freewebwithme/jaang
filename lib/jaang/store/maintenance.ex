defmodule Jaang.Store.Maintenance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Repo
  import Ecto.Query
  alias Jaang.Store.Maintenance

  @moduledoc """
  Schema module for Maintenance status
  """

  schema "maintenances" do
    field :message, :string
    field :in_maintenance_mode, :boolean, default: false
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :archived, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = maintenance, attrs) do
    maintenance
    |> cast(attrs, [:message, :in_maintenance_mode, :start_datetime, :end_datetime, :archived])
    |> validate_required([:message, :in_maintenance_mode])
    |> validate_length(:message, min: 10)
  end

  def create_maintenance(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  # Editing archived maintenance is not allowed
  def update_maintenance(%__MODULE__{archived: true} = maintenance, attrs) do
    IO.puts("Archived maintenance can't be edited")

    changeset =
      maintenance
      |> changeset(attrs)
      |> add_error(:archived, "Archived maintenance can not be edited.")

    {:error, changeset}
  end

  # Archiving a maintenance
  def update_maintenance(%__MODULE__{} = maintenance, %{"archived" => "true"} = attrs) do
    IO.puts("Archiving maintenance")
    now = Timex.now()
    updated_attrs = attrs |> Map.put("end_datetime", now) |> Map.put("in_maintenance_mode", false)

    maintenance
    |> changeset(updated_attrs)
    |> Repo.update()
  end

  def update_maintenance(%__MODULE__{} = maintenance, attrs) do
    IO.puts("Updating maintenance")
    IO.inspect(attrs)

    maintenance
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete_maintenance(%__MODULE__{} = maintenance) do
    maintenance |> Repo.delete()
  end

  def list_maintenances() do
    query = from m in Maintenance, order_by: [desc: m.inserted_at]
    Repo.all(query)
  end

  def get_maintenance(id) do
    Repo.get_by(Maintenance, id: id)
  end

  def change_maintenance(%__MODULE__{} = maintenance, attrs) do
    maintenance |> changeset(attrs)
  end

  @timezone "America/Los_Angeles"

  def check_maintenance_mode() do
    # get latest maintenance and check if it is on
    query = from m in Maintenance, order_by: [desc: m.inserted_at], limit: 1

    case Repo.one!(query) do
      nil ->
        nil

      %__MODULE__{} = maintenance ->
        if maintenance.in_maintenance_mode do
          maintenance
        else
          nil
        end
    end
  end
end
