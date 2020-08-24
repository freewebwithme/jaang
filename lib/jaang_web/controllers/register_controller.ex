defmodule JaangWeb.RegisterController do
  use JaangWeb, :controller

  alias Jaang.AccountManager
  alias JaangWeb.UserAuth

  def index(conn, _params) do
    changeset = AccountManager.change_user(%Jaang.Account.User{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    IO.puts("Inspecting register params")
    IO.inspect(user_params)

    case AccountManager.create_user_with_profile(user_params) do
      {:ok, user} ->
        # TODO: Send confirmation email

        conn
        |> put_flash(:info, "Your account is created successfully")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end
end
