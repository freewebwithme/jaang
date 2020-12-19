defmodule Jaang.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Invoice

  schema "invoices" do
    field :invoice_number, :string
    field :subtotal, Money.Ecto.Amount.Type
    field :driver_tip, Money.Ecto.Amount.Type
    field :delivery_fee, Money.Ecto.Amount.Type
    field :service_fee, Money.Ecto.Amount.Type
    field :sales_tax, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type
    field :total_items, :integer
    field :payment_method, :string
    field :pm_intent_id, :string
    field :status, Ecto.Enum, values: [:cart, :refunded, :completed, :delivered]

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
      :address_id,
      :status,
      :pm_intent_id,
      :invoice_number,
      :total_items
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
