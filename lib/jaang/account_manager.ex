defmodule Jaang.AccountManager do
  alias Jaang.Account.Accounts

  defdelegate create_user(attrs), to: Accounts
  defdelegate create_address(user, attrs), to: Accounts
  defdelegate get_user(id), to: Accounts
  defdelegate change_user(user, attrs \\ %{}), to: Accounts
  defdelegate change_profile(profile, attrs \\ %{}), to: Accounts
  defdelegate delete_session_token(token), to: Accounts
  defdelegate generate_user_session_token(user), to: Accounts
  defdelegate get_user_by_session_token(token), to: Accounts
  defdelegate create_user_with_profile(attrs), to: Accounts
  defdelegate get_user_by_email_and_password(email, password), to: Accounts
end
