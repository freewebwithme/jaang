defmodule JaangWeb.RegisterController do
  use JaangWeb, :controller

  alias Jaang.AccountManager
  alias JaangWeb.UserAuth

  def index(conn, _params) do
    changeset = AccountManager.change_user(%Jaang.Account.User{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"g-recaptcha-response" => recaptcha_response, "user" => user_params}) do
    case Recaptcha.verify(recaptcha_response) do
      {:ok, _response} ->
        case AccountManager.create_user_with_profile(user_params) do
          {:ok, user} ->
            Jaang.EmailManager.send_welcome_email(user)

            conn
            |> put_flash(:info, "Your account is created successfully")
            |> UserAuth.log_in_user(user)

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "index.html", changeset: changeset)
        end

      _ ->
        conn
        |> put_flash(:error, "Recaptch value is invalid, Try again")
        |> redirect(to: Routes.register_path(conn, :index))
    end
  end
end
