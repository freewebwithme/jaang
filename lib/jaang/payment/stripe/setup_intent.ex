defmodule Jaang.Payment.Stripe.SetupIntent do
  alias Stripe.SetupIntent

  def create_setup_intent(stripe_id, payment_method_id) do
    SetupIntent.create(%{customer: stripe_id, payment_method: payment_method_id})
  end
end
