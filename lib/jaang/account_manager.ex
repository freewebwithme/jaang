defmodule Jaang.AccountManager do
  alias Jaang.Account.Accounts

  defdelegate create_user(attrs), to: Accounts
  defdelegate create_address(user, attrs), to: Accounts
  defdelegate get_user(id), to: Accounts
  defdelegate change_user(user, attrs \\ %{}), to: Accounts
end
