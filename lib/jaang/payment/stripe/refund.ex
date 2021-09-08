defmodule Jaang.Payment.Stripe.Refund do
  alias Stripe.Refund

  def create_refund(payment_intent_id, amount) do
    Refund.create(%{payment_intent: payment_intent_id, amount: amount})
  end
end
