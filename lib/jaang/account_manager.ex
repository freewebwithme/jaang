defmodule Jaang.AccountManager do
  alias Jaang.Account.{Accounts}

  defdelegate create_user(attrs), to: Accounts
  defdelegate create_address(user, attrs), to: Accounts
  defdelegate get_user(id), to: Accounts
  defdelegate update_user(user, attrs \\ %{}), to: Accounts
  defdelegate change_user(user, attrs \\ %{}), to: Accounts
  defdelegate change_profile(profile, attrs \\ %{}), to: Accounts
  defdelegate update_profile(user, attrs), to: Accounts
  defdelegate get_user_by_email(email), to: Accounts
  defdelegate create_user_with_profile(attrs), to: Accounts
  defdelegate create_user_with_profile_using_google(attrs), to: Accounts
  defdelegate get_user_by_email_and_password(email, password), to: Accounts
  defdelegate change_user_password(user), to: Accounts

  defdelegate authenticate_google_idToken(idToken), to: Accounts
  defdelegate google_signin_from_mobile(email, display_name, photo_url), to: Accounts
  # Session
  defdelegate delete_session_token(token), to: Accounts
  defdelegate generate_user_session_token(user), to: Accounts
  defdelegate get_user_by_session_token(token), to: Accounts

  # Reset password
  defdelegate deliver_user_reset_password_instructions(user, func), to: Accounts
  defdelegate get_user_by_reset_password_token(token), to: Accounts
  defdelegate reset_user_password(user, attrs), to: Accounts

  # Account confirm
  defdelegate deliver_user_confirmation_instructions(user, func), to: Accounts
  defdelegate confirm_user(token), to: Accounts

  # Address
end
