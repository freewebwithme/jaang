defmodule JaangWeb.Resolvers.OrderResolver do
  alias Jaang.{AccountManager, InvoiceManager}

  def fetch_invoices(_, %{token: user_token}, _) do
    user = AccountManager.get_user_by_session_token(user_token)
    invoices = InvoiceManager.get_invoices(user.id)
    {:ok, invoices}
  end
end
