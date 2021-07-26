defmodule Jaang.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Invoice

  @derive {Jason.Encoder, except: [:__meta__, :employees]}
  schema "invoices" do
    field :invoice_number, :string
    field :total_items, :integer
    field :payment_method, :string
    field :pm_intent_id, :string

    field :status, Ecto.Enum,
      values: [
        :cart,
        :refunded,
        :submitted,
        :shopping,
        :partially_packed,
        :packed,
        :on_the_way,
        :partially_delivered,
        :delivered
      ]

    field :invoice_placed_at, :utc_datetime
    field :grand_total_price, Money.Ecto.Amount.Type

    belongs_to :user, Jaang.Account.User
    has_many :orders, Jaang.Checkout.Order
    # embeds_many :receipt_photos, Jaang.Invoice.ReceiptPhoto, on_replace: :delete

    many_to_many :employees, Jaang.Admin.Account.Employee.Employee,
      join_through: Jaang.Admin.Account.Employee.EmployeeAssignedInvoice,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  # Implementing Jason.Encoder for Money type
  # Convert %Money{amount: 0, currency: :USD} to $0
  defimpl Jason.Encoder, for: Money do
    def encode(struct, opts) do
      Jason.Encode.string(Money.to_string(struct), opts)
    end
  end

  @doc false
  def changeset(%Invoice{} = invoice, attrs) do
    fields = [
      :payment_method,
      :user_id,
      :status,
      :pm_intent_id,
      :invoice_number,
      :total_items,
      :invoice_placed_at,
      :grand_total_price
    ]

    invoice
    |> cast(attrs, fields)
    |> validate_required([
      :user_id
    ])
  end
end
