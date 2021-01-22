defmodule JaangWeb.Admin.StaffLoginLive do
  use JaangWeb, :live_view
  alias Jaang.Admin.Account.{AdminUser, AdminAccounts}
  alias JaangWeb.Router.Helpers, as: Routes
  alias Ecto.Changeset

  def mount(_params, _session, socket) do
    changeset = AdminUser.changeset(%AdminUser{})
    {:ok, assign(socket, changeset: changeset, trigger_submit: false)}
  end

  def handle_event("save", %{"admin_user" => params}, socket) do
    %{"email" => email, "password" => password} = params

    case AdminAccounts.get_user_by_email_and_password(email, password) do
      nil ->
        changeset =
          AdminUser.changeset(%AdminUser{}, %{email: email, password: password})
          |> Changeset.add_error(:email, "information is not correct")
          |> Changeset.add_error(:password, "information is not correct")

        IO.inspect(changeset)

        {:noreply,
         assign(
           socket,
           changeset: changeset,
           trigger_submit: false
         )}

      %AdminUser{} = _admin_user ->
        changeset = AdminUser.changeset(%AdminUser{})

        {:noreply,
         assign(
           socket,
           changeset: changeset,
           trigger_submit: true
         )}
    end
  end
end
