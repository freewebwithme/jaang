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
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         %{} = user <- UserAuthMobile.get_user_by_session_token(token) do
      IO.puts("user has bearer token in context")
      IO.inspect(token)

      %{current_user: user}
    else
      _ ->
        IO.puts("inspecting conn")
        IO.inspect(conn)
        IO.puts("Can't find bearer, not authenticated")
        %{}
    end
  end
end
