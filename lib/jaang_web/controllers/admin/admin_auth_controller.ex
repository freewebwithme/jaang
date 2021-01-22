defmodule JaangWeb.Admin.AdminAuthController do
  use JaangWeb, :controller

  alias Jaang.Admin.Account.{AdminAccounts}
  alias JaangWeb.Admin.AdminUserAuth

  def log_in(conn, %{"admin_user" => admin_params}) do
    %{"email" => email, "password" => password} = admin_params

    if admin_user = AdminAccounts.get_user_by_email_and_password(email, password) do
      AdminUserAuth.log_in_user(conn, admin_user, %{})
    else
      live_render(conn, JaangWeb.Admin.StaffLoginLive)
    end
  end
end
