defmodule JaangWeb.Admin.AdminUserAuth do
  @moduledoc """
  User authentication module for web client(Phoenix)
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Jaang.Admin.Account.AdminAccounts
  alias JaangWeb.Admin.HomeLive
  alias JaangWeb.Router.Helpers, as: Routes

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, admin_user, params \\ %{}) do
    token = AdminAccounts.generate_user_session_token(admin_user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> assign(:admin_user_token, token)
    |> assign(:admin_id, admin_user.id)
    |> put_session(:admin_user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> maybe_write_remember_me_cookies(token, params)
    |> put_flash(:info, "You've successfully logged in")
    |> redirect(to: user_return_to || Routes.live_path(conn, HomeLive))
  end

  defp maybe_write_remember_me_cookies(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookies(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out

  It clears all session data for safety.  See renew_session
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :admin_user_token)
    user_token && AdminAccounts.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      JaangWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> put_flash(:info, "You are logged out")
    |> redirect(to: "/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_admin_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)

    if(user_token == nil) do
      conn
    else
      admin_user = AdminAccounts.get_user_by_session_token(user_token)

      assign(conn, :admin_user, admin_user)
      |> assign(:user_token, user_token)
      |> assign(:admin_id, admin_user.id)
    end
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:admin_user] do
      conn
      |> redirect(to: "/admin")
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user e-mail is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:admin_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page")
      |> redirect(to: Routes.live_path(conn, JaangWeb.Admin.StaffLoginLive))
      |> halt()
    end
  end
end
