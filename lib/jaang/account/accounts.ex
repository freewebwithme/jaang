defmodule Jaang.Account.Accounts do
  alias Jaang.{Repo, ProfileManager, EmailManager}
  alias Jaang.Account.{User, UserToken, Address, Profile, Validator}
  alias Jaang.Distance
  alias Ecto.Changeset
  import Ecto.Query


  @doc """
  attrs = %{email: "user@example.com", profile: %{ first_name: "John", last_name: "Doe"}}
  """
  @spec create_user_with_profile(map) ::
          {:ok, User.t() | {:error, Ecto.Changeset.t() }}
  def create_user_with_profile(attrs) do
    case create_user(attrs) do
      {:ok, user} ->
      # Send confirmation email
      deliver_user_confirmation_instructions(
        user,
        &JaangWeb.Router.Helpers.account_confirmation_url(JaangWeb.Endpoint, :confirm, &1)
      )

      {:ok, user}

      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Create user with information in attrs and send comfirmatin email
  attrs = %{email: "user@example.com", profile: %{ first_name: "John", last_name: "Doe"}}
  """
  @spec create_user_with_profile_using_google(map) :: {:ok, User.t() | {:error, Ecto.Changeset.t() }}
  def create_user_with_profile_using_google(attrs) do
    case create_user_using_google(attrs) do
      {:ok, user} ->
        user = Repo.get_by(User, id: user.id) |> Repo.preload(:profile)

        # Send confirmation email
        deliver_user_confirmation_instructions(
          user,
          &JaangWeb.Router.Helpers.account_confirmation_url(JaangWeb.Endpoint, :confirm, &1)
        )

        {:ok, user}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Create user using google information
  """
  @spec create_user_using_google(map) :: {:ok, User.t() | {:error, Ecto.Changeset.t()}}
  def create_user_using_google(attrs) do
    %User{} |> User.google_changeset(attrs) |> Repo.insert()
  end

  @spec create_user(map) :: {:ok, User.t() | {:error, Ecto.Changeset.t()}}
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec create_address(User.t(), map) :: {:ok, Address.t() | {:error, Ecto.Changeset.t()}}
  def create_address(%User{} = user, attrs) do
    attrs = Map.put(attrs, :user_id, user.id)

    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get a user with user id and preloaded profile, addresses with distance schema
  """
  @spec get_user(integer()) :: User.t() | nil
  def get_user(id) do
    Repo.get_by(User, id: id) |> Repo.preload([:profile, addresses: [:distance]])
  end

  @doc """
  Return changeset from registration_changeset
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  @doc"""

  Delete a user
  """
  def delete_user(user) do
    user
    |> Repo.delete!()
  end

  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Basically updating profile information and also
  if user is changing default store,
  update distance schema also
  """
  @spec update_profile(User.t(), map) :: Jaang.Account.Profile.t()
  def update_profile(user, attrs) do
    profile = user.profile
    changeset = change_profile(profile, attrs)
    store_id = Changeset.get_change(changeset, :store_id)

    cond do
      store_id == nil ->
        changeset |> Repo.update!()

      true ->
        profile = changeset |> Repo.update!()

        # Default store is changed, check if current user's address
        # and store address if deilvery is available
        # Check if distance is already calculated

        # Check if only user has any address
        if !Enum.empty?(ProfileManager.get_all_addresses(user.id)) do
          Distance.check_and_update_store_distance(user, store_id)
        end

        profile
    end
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
    user = Repo.get_by(User, email: email) |> Repo.preload(:profile)
    if Validator.valid_password?(user, password), do: user
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
    Repo.get_by(User, email: email) |> Repo.preload(:profile)
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
    {_encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

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
    Repo.one(query) |> Repo.preload([:profile, addresses: [:distance]])
  end

  ## Google Sign in

  @doc """
  Accept idToken and name and return User
  If user exists return an user
  if user doesn't exist, create a new user

  This function will be use for mobile google sign in
  """
  def authenticate_google_idToken(idToken) do
    with {:ok, result} <- Jaang.Account.GoogleToken.verify_and_validate(idToken) do
      email = result["email"]

      if user = get_user_by_email(email) do
        {:ok, user}
      else
        attrs = %{
          email: email,
          profile: %{
            first_name: result["given_name"],
            last_name: result["family_name"]
          }
        }

        create_user_with_profile_using_google(attrs)
      end
    else
     {:error, message} -> {:error, message}
      _ -> :error
    end
  end

  # @doc """
  # Mobile client sign in using Google Sign in
  # """
  # @spec google_signin_from_mobile(String.t(), String.t(), String.t()) :: {:ok, %User{}}
  # def google_signin_from_mobile(email, display_name, photo_url) when is_nil(display_name) do
  #  if user = get_user_by_email(email) do
  #    {:ok, user}
  #  else
  #    attrs = %{
  #      email: email,
  #      profile: %{
  #        first_name: nil,
  #        last_name: nil,
  #        photo_url: photo_url
  #      }
  #    }

  #    {:ok, user} = create_user_with_profile_using_google(attrs)
  #    {:ok, user}
  #  end
  # end

  # def google_signin_from_mobile(email, display_name, photo_url) do
  #  if user = get_user_by_email(email) do
  #    {:ok, user}
  #  else
  #    names = String.split(display_name, " ")
  #    # Get first name
  #    [first_name] = Enum.take(names, 1)
  #    # Get last name
  #    [last_name] = Enum.take(names, -1)

  #    attrs = %{
  #      email: email,
  #      profile: %{
  #        first_name: first_name,
  #        last_name: last_name,
  #        photo_url: photo_url
  #      }
  #    }

  #    {:ok, user} = create_user_with_profile_using_google(attrs)
  #    {:ok, user}
  #  end
  # end

  ## Absinthe

  def data() do
    Dataloader.Ecto.new(Jaang.Repo, query: &query/2)
  end

  # Return addresses order by inserted at
  def query(Address, _) do
    from addr in Address, order_by: addr.inserted_at
  end

  def query(queryable, _) do
    queryable
  end
end
