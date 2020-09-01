defmodule Jaang.AccountManager do
  alias Jaang.Account.{Accounts, UserAuth}

  defdelegate create_user(attrs), to: Accounts
  defdelegate create_address(user, attrs), to: Accounts
  defdelegate get_user(id), to: Accounts
  defdelegate change_user(user, attrs \\ %{}), to: Accounts
  defdelegate change_profile(profile, attrs \\ %{}), to: Accounts
  defdelegate delete_session_token(token), to: Accounts
  defdelegate generate_user_session_token(user), to: Accounts
  defdelegate get_user_by_email(email), to: Accounts
  defdelegate get_user_by_session_token(token), to: Accounts
  defdelegate create_user_with_profile(attrs), to: Accounts
  defdelegate create_user_with_profile_using_google(attrs), to: Accounts
  defdelegate get_user_by_email_and_password(email, password), to: Accounts
  defdelegate change_user_password(user), to: Accounts

  # User auth
  defdelegate log_in_user(email, password), to: UserAuth

  # Reset password
  defdelegate deliver_user_reset_password_instructions(user, func), to: Accounts
  defdelegate get_user_by_reset_password_token(token), to: Accounts
  defdelegate reset_user_password(user, attrs), to: Accounts

  # Account confirm
  defdelegate deliver_user_confirmation_instructions(user, func), to: Accounts
  defdelegate confirm_user(token), to: Accounts
end
