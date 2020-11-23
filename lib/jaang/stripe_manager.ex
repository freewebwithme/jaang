defmodule Jaang.StripeManager do
  alias Jaang.Payment.Stripe.{Customer, SetupIntent, PaymentMethod}

  defdelegate create_customer(email), to: Customer
  defdelegate update_customer(stripe_id, attrs), to: Customer
  defdelegate retrieve_customer(stripe_id), to: Customer

  defdelegate create_setup_intent(stripe_id, payment_method_id), to: SetupIntent

  defdelegate get_all_cards(stripe_id), to: PaymentMethod
  defdelegate create_payment_method(card_token), to: PaymentMethod
  defdelegate retrieve_payment_method(payment_method_id), to: PaymentMethod
  defdelegate attach_to_customer(payment_method_id, stripe_id), to: PaymentMethod
  defdelegate delete_payment_method(payment_method_id), to: PaymentMethod
end
