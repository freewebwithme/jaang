defmodule Jaang.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Invoice

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "invoices" do
    field :invoice_number, :string
    field :subtotal, Money.Ecto.Amount.Type
    field :driver_tip, Money.Ecto.Amount.Type
    field :delivery_fee, Money.Ecto.Amount.Type
    field :service_fee, Money.Ecto.Amount.Type
    field :sales_tax, Money.Ecto.Amount.Type
    field :item_adjustment, Money.Ecto.Amount.Type
    field :total, Money.Ecto.Amount.Type
    field :total_items, :integer
    field :payment_method, :string
    field :pm_intent_id, :string

    field :status, Ecto.Enum,
      values: [:cart, :refunded, :submitted, :shopping, :packed, :on_the_way, :delivered]

    field :delivery_time, :string

    # Embed address information
    field :recipient, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :business_name, :string
    field :zipcode, :string
    field :city, :string
    field :state, :string
    field :instructions, :string

    field :phone_number, :string

    field :shopper_id, :id
    field :driver_id, :id
    belongs_to :user, Jaang.Account.User
    has_many :orders, Jaang.Checkout.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    fields = [
      :subtotal,
      :item_adjustment,
      :driver_tip,
      :delivery_fee,
      :service_fee,
      :sales_tax,
      :total,
      :payment_method,
      :user_id,
      :status,
      :pm_intent_id,
      :invoice_number,
      :total_items,
      :recipient,
      :address_line_one,
      :address_line_two,
      :business_name,
      :zipcode,
      :city,
      :state,
      :instructions,
      :phone_number,
      :delivery_time
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
