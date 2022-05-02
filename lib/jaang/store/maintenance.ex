defmodule Jaang.Store.Maintenance do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Repo

  @moduledoc """
  Schema module for Maintenance status
  """

  schema "maintenance" do
    field :message, :string
    field :in_maintenance_mode, :boolean, default: false
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = maintenance, attrs) do
    maintenance
    |> cast(attrs, [:message, :in_maintenance_mode, :start_datetime, :end_datetime])
  end

  def create_maintenance(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update_maintenance(%__MODULE__{} = maintenance, attrs) do
    maintenance
    |> changeset(attrs)
    |> Repo.update!()
  end

  def delete_maintenance(%__MODULE__{} = maintenance) do
    maintenance |> Repo.delete()
  end

  def list_maintenances() do
    Repo.all(%__MODULE__{})
  end

  def get_maintenance(id) do
    Repo.get_by(%__MODULE__{}, id: id)
  end
end
