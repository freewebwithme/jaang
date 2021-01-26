defmodule JaangWeb.Plugs.AuthorizeAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  alias JaangWeb.Router.Helpers, as: Routes
  alias Jaang.Admin.Account.{AdminAccounts, AdminUser}

  def init(_opts), do: nil

  def call(conn, _opts) do
    admin_user_token = get_session(conn, :admin_user_token)
    # IO.puts("Inspecting admin_user_token from Plugs")
    # IO.inspect(admin_user_token)

    with false <- is_nil(admin_user_token),
         %AdminUser{} = _admin <-
           AdminAccounts.get_user_by_session_token(admin_user_token) do
      conn
    else
      true ->
        conn
        |> put_flash(:error, "You are not allowed to access")
        |> redirect(to: Routes.live_path(conn, JaangWeb.Admin.StaffLoginLive))
        |> halt()

      nil ->
        conn
        |> put_flash(:error, "You are not allowed to access")
        |> redirect(to: Routes.live_path(conn, JaangWeb.Admin.StaffLoginLive))
        |> halt()
    end
  end
end
