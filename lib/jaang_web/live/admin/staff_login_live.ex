defmodule JaangWeb.Admin.StaffLoginLive do
  use JaangWeb, :live_view
  alias Jaang.Admin.Account.{AdminUser, AdminAccounts}

  def mount(_params, _session, socket) do
    changeset = AdminUser.changeset(%AdminUser{})
    {:ok, assign(socket, changeset: changeset, trigger_submit: false, error_message: nil)}
  end

  def handle_event("save", %{"admin_user" => params}, socket) do
    %{"email" => email, "password" => password} = params

    case AdminAccounts.get_user_by_email_and_password(email, password) do
      nil ->
        changeset = AdminUser.changeset(%AdminUser{}, %{email: email, password: password})

        {:noreply,
         assign(
           socket,
           changeset: changeset,
           trigger_submit: false,
           error_message: "Failed to login"
         )}

      %AdminUser{} = _admin_user ->
        changeset = AdminUser.changeset(%AdminUser{}, %{email: email, password: password})
        IO.puts("Found admin user")

        {:noreply,
         assign(
           socket,
           changeset: changeset,
           trigger_submit: true,
           error_message: nil
         )}
    end
  end
end
