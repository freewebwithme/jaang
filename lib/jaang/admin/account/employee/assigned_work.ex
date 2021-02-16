defmodule Jaang.Admin.Account.Employee.AssignedWork do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assigned_works" do
    field :invoice_id, :id

    timestamps(type: :utc_datetime)
  end
end
