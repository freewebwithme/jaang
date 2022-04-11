defmodule JaangWeb.Plugs.SetCurrentUser do
  @behaviour Plug
  import Plug.Conn

  alias Jaang.Account.UserAuthMobile

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    ["Bearer " <> token] = get_req_header(conn, "authorization")

    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- UserAuthMobile.get_user_by_session_token(token) do
      %{current_user: user}
    else
      _ ->
        IO.puts "SetCurrentUser Plug authorization is empty or token is invalid"
        %{}
    end
  end
end
