defmodule Jaang.Payment.Stripe.PaymentMethod do
  alias Stripe.PaymentMethod

  def get_all_cards(stripe_id) do
    PaymentMethod.list(%{customer: stripe_id, type: "card"})
  end
end
