defmodule Jaang.Account.Accounts do
  alias Jaang.Repo
  alias Jaang.Account.{User, UserToken, Address, Profile}

  # TODO: write a test
  def create_user_with_profile(attrs) do
    with {:ok, user} <- create_user(attrs) do
      {:ok, user}
    else
      {:error, error} -> {:error, error}
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
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

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  ## Session

  @doc """
  Generates a session token.
  """
  # TODO: Need a test
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  # TODO: Need a test
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  # TODO: Need a test
  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end
end
