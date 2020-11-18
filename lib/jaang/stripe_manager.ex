defmodule Jaang.StripeManager do
  alias Jaang.Payment.Stripe.{Customer, SetupIntent, PaymentMethod}

  defdelegate create_customer(email), to: Customer
  defdelegate create_setup_intent(stripe_id, payment_method_id), to: SetupIntent
  defdelegate get_all_cards(stripe_id), to: PaymentMethod
end
