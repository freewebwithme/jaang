defmodule Jaang.Admin.CustomerService.CustomerMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customer_messages" do
    field :message, :string
    field :status, Ecto.Enum, values: [:in_progress, :new_request, :completed]

    belongs_to :user, Jaang.Account.User
    belongs_to :order, Jaang.Checkout.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer_message, attrs) do
    customer_message
    |> cast(attrs, [:message, :status, :user_id, :order_id])
    |> validate_required([:message, :status])
  end
end
