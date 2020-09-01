defmodule JaangWeb.Resolvers.AccountResolver do
  alias Jaang.AccountManager

  def log_in(_, %{email: email, password: password}, _) do
    {user, token} = AccountManager.log_in_user(email, password)

    {:ok, %{user: user, token: token}}
  end
end
