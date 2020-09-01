defmodule JaangWeb.Plugs.SetCurrentUser do
  @behaviour Plug
  import Plug.Conn

  alias JaangWeb.UserAuth
  alias Jaang.Account.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] = get_req_header(conn, "authorization"),
         %User{} = user <- UserAuth.fetch_current_user_for_graphql(conn) do
      IO.puts("user has bearer token in context")

      %{current_user: user}
    else
      _ ->
        IO.puts("Can't find bearer")
        %{}
    end
  end
end
