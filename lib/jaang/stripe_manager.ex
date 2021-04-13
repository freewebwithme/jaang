defmodule Jaang.StripeManager do
  alias Jaang.Payment.Stripe.{Customer, SetupIntent, PaymentMethod, PaymentIntent}

  defdelegate create_customer(email), to: Customer
  defdelegate update_customer(stripe_id, attrs), to: Customer
  defdelegate retrieve_customer(stripe_id), to: Customer

  defdelegate create_setup_intent(stripe_id, payment_method_id), to: SetupIntent

  defdelegate get_all_cards(stripe_id), to: PaymentMethod
  defdelegate create_payment_method(card_token), to: PaymentMethod
  defdelegate create_payment_method(card_number, exp_month, exp_year, cvc), to: PaymentMethod
  defdelegate retrieve_payment_method(payment_method_id), to: PaymentMethod
  defdelegate attach_to_customer(payment_method_id, stripe_id), to: PaymentMethod
  defdelegate delete_payment_method(payment_method_id), to: PaymentMethod
  defdelegate get_default_payment_method(stripe_id), to: PaymentMethod

  defdelegate set_default_payment_method(stripe_id, payment_method_id), to: PaymentMethod
  # Payment Intent

  @doc """
  Used for place a payment on hold
  returns payment intent struct
  """
  defdelegate create_payment_intent(amount, stripe_id, payment_method_id), to: PaymentIntent

  @doc """
  Finally capture the payment
  params: payment_intent_id, amount to capture
  """
  defdelegate capture_payment_intent(payment_intent_id, amount_to_capture), to: PaymentIntent
end
