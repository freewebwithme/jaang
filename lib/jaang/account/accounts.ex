defmodule Jaang.Account.Accounts do
  alias Jaang.Repo
  alias Jaang.Account.{User, UserToken, Address, Profile}
  alias Jaang.EmailManager

  @doc """
  attrs = %{email: "user@example.com",
            profile: %{
              first_name: "John",
              last_name: "Doe"
              }
            }
  """
  def create_user_with_profile(attrs) do
    with {:ok, user} <- create_user(attrs) do
      {:ok, user}
    else
      {:error, error} -> {:error, error}
    end
  end

  def create_user_with_profile_using_google(attrs) do
    case create_user_using_google(attrs) do
      {:ok, user} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  def create_user_using_google(attrs) do
    %User{} |> User.google_changeset(attrs) |> Repo.insert()
  end

  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()

    # TODO: Maybe preload profile, addresses?
    # |> Repo.preload([:profile, :addresses])
  end

  def create_address(%User{} = user, attrs) do
    attrs = Map.put(attrs, :user_id, user.id)

    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get_by(User, id: id) |> Repo.preload([:profile, :addresses])
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
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
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
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
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)

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

  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      url = confirmation_url_fun.(encoded_token)

      # Send email
      EmailManager.send_confirmation_instructions(user, url)
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
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
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
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
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    url = reset_password_url_fun.(encoded_token)
    # Send email
    EmailManager.send_reset_password_email(user, url)
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  ## Google Sign in

  @doc """
  Accept idToken and name and return User
  If user exists return an user
  if user doesn't exist, create a new user

  This function will be use for mobile google sign in
  """
  ### TODO: Can't figure out why can't get idToken from flutter
  ### not using it until find a solution.
  def authenticate_google_idToken(idToken) do
    with {:ok, result} <- Jaang.Account.GoogleToken.verify_and_validate(idToken) do
      email = result["email"]

      if user = get_user_by_email(email) do
        {:ok, user}
      else
        attrs = %{
          email: email,
          first_name: result["given_name"],
          last_name: result["family_name"]
        }

        user = create_user_with_profile_using_google(attrs)
        {:ok, user}
      end
    else
      _ -> :error
    end
  end

  def google_signin_from_mobile(email, display_name) do
    if user = get_user_by_email(email) do
      {:ok, user}
    else
      [first_name, last_name] = String.split(display_name, " ")

      attrs = %{
        email: email,
        profile: %{
          first_name: first_name,
          last_name: last_name
        }
      }

      {:ok, user} = create_user_with_profile_using_google(attrs)
      {:ok, user}
    end
  end

  ## Absinthe

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
