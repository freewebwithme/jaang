defmodule Jaang.Admin.Account.AdminAccounts do
  alias Jaang.Admin.Account.{AdminUser, AdminUserToken}
  alias Jaang.Account.User
  alias Jaang.{Repo, EmailManager}

  def create_admin_user(attrs) do
    %AdminUser{}
    |> AdminUser.changeset(attrs)
    |> Repo.insert!()
  end

  def get_admin_user(id) do
    Repo.get_by(AdminUser, id: id)
  end

  def delete_admin_user(admin_user = %AdminUser{}) do
    Repo.delete!(admin_user)
  end

  def update_admin_user(admin_user, attrs) do
    admin_user
    |> AdminUser.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Log in a user using email and password

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "secret")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "wrong")
      nil
  """

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(AdminUser, email: email)
    if AdminUser.valid_password?(user, password), do: user
  end

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(AdminUser, email: email)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs)
  end

  @doc """
  Delivers the update e-mail instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%AdminUser{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, admin_user_token} =
      AdminUserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(admin_user_token)

    # Send email
  end

  ## Confirmation

  @doc """
  Delivers the confirmation e-mail instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :confirm, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :confirm, &1))
      {:error, :already_confirmed}

  """

  def deliver_user_confirmation_instructions(%AdminUser{} = admin_user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if admin_user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, admin_user_token} = AdminUserToken.build_email_token(admin_user, "confirm")
      Repo.insert!(admin_user_token)
      url = confirmation_url_fun.(encoded_token)

      # Send email
      EmailManager.send_confirmation_instructions(admin_user, url)
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- AdminUserToken.verify_email_token_query(token, "confirm"),
         %AdminUser{} = admin_user <- Repo.one(query),
         {:ok, %{user: admin_user}} <- Repo.transaction(confirm_user_multi(admin_user)) do
      {:ok, admin_user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(admin_user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:admin_user, AdminUser.confirm_changeset(admin_user))
    |> Ecto.Multi.delete_all(
      :tokens,
      AdminUserToken.user_and_contexts_query(admin_user, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- AdminUserToken.verify_email_token_query(token, "reset_password"),
         %AdminUser{} = admin_user <- Repo.one(query) do
      admin_user
    else
      _ -> nil
    end
  end

  @doc """
  Delivers the reset password e-mail to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%AdminUser{} = admin_user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, admin_user_token} =
      AdminUserToken.build_email_token(admin_user, "reset_password")

    Repo.insert!(admin_user_token)
    url = reset_password_url_fun.(encoded_token)
    # Send email
    EmailManager.send_reset_password_email(admin_user, url)
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(admin_user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, AdminUser.password_changeset(admin_user, attrs))
    |> Ecto.Multi.delete_all(:tokens, AdminUserToken.user_and_contexts_query(admin_user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: admin_user}} -> {:ok, admin_user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(admin_user) do
    {token, admin_user_token} = AdminUserToken.build_session_token(admin_user)
    Repo.insert!(admin_user_token)
    token
  end

  def delete_session_token(token) do
    Repo.delete_all(AdminUserToken.token_and_context_query(token, "session"))
    :ok
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = AdminUserToken.verify_session_token_query(token)
    Repo.one(query)
  end
end
