defmodule JaangWeb.Plugs.SetCurrentEmployee do
  @behaviour Plug
  import Plug.Conn

  alias Jaang.Admin.Account.EmployeeAuthMobile

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    conn = Absinthe.Plug.put_options(conn, context: context)
    IO.puts("Inspecting conn")
    IO.inspect(conn)
    conn
  end

  defp build_context(conn) do
    %Plug.Conn{
      private: %{
        :absinthe => %{
          context: prev_context
        }
      }
    } = conn

    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, employee} <- EmployeeAuthMobile.get_employee_by_session_token(token) do
      Map.put(prev_context, :current_employee, employee)
    else
      _ ->
        # Even though there is no current employee,
        # I need to keep previous context for user
        prev_context
    end
  end
end
