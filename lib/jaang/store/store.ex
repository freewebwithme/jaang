defmodule Jaang.Store do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Partner(Store)'s Schema
  """

  schema "stores" do
    field :name, :string
    field :description, :string
    field :price_info, :string
    field :available_hours, :string
    field :address, :string
    field :phone_number, :string
    field :store_logo, :string

    has_many :products, Jaang.Product

    many_to_many :employees, Jaang.Admin.Account.Employee.Employee,
      join_through: Jaang.Admin.Account.Employee.EmployeeAssignedStore,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Jaang.Store{} = store, attrs) do
    fields = [
      :name,
      :description,
      :price_info,
      :available_hours,
      :address,
      :phone_number,
      :store_logo
    ]
    store
    |> cast(attrs, fields)
    |> validate_required(fields)
  end
end
