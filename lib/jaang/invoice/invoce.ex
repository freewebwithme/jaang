defmodule Jaang.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Invoice

  schema "invoices" do
    field :subtotal, :string
    field :driver_tip, :string
    field :delivery_fee, :string
    field :service_fee, :string
    field :sales_tax, :string
    field :total, :string

    field :payment_method, :string
    field :status, Ecto.Enum, values: [:cart, :refund, :completed, :delivered]

    field :address_id, :id
    has_many :orders, Jaang.Checkout.Order
    belongs_to :user, Jaang.Account.User

    timestamps()
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    fields = [
      :subtotal,
      :driver_tip,
      :delivery_fee,
      :service_fee,
      :sales_tax,
      :total,
      :payment_method,
      :user_id,
      :address_id
    ]

    invoice
    |> cast(attrs, fields)
    |> validate_required([
      :subtotal,
      :driver_tip,
      :delivery_fee,
      :service_fee,
      :sales_tax,
      :total,
      :user_id
    ])
  end
end
