defmodule Jaang.Admin.Account.Employee.AssignedWork do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assigned_works" do
    field :invoice_id, :id
    field :assigned_at, :utc_datetime
    field :finished_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = assigned_works, attrs) do
    assigned_works
    |> cast(attrs, [:invoice_id, :assigned_at, :finished_at])
  end
end
