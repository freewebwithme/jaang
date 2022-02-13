defmodule Jaang.AccountsTest do
  use Jaang.DataCase, async: true

  alias Jaang.AccountManager
  alias Jaang.Account.User

  setup do
    attrs = %{
      email: "test@example.com",
      password: "secretsecret",
      password_confirmation: "secretsecret",
      profile: %{
        first_name: "Taehwan",
        last_name: "Kim",
        phone: "2135055819"
      }
    }

    {:ok, user} = AccountManager.create_user_with_profile(attrs)

    {:ok, %{user: user}}
  end

  test "create user with profile correctly", context do
    user = context[:user]
    # Load user with profile
    query = from u in User, where: u.id == ^user.id
    saved_user = Repo.one(query) |> Repo.preload(:profile)

    assert saved_user.email == "test@example.com"
    assert saved_user.profile.first_name == "Taehwan"
    assert saved_user.profile.last_name == "Kim"
    assert saved_user.profile.phone == "2135055819"

    refute saved_user.password == "secret"
  end

  test "create addresses", context do
    user = context[:user]

    attrs = %{
      recipient: "John",
      address_line_one: "777 Good st",
      address_line_two: "APT 320",
      business_name: "Good",
      zipcode: "90099",
      city: "Los Angeles",
      state: "CA",
      instructions: "instructions"
    }

    {:ok, address1} = AccountManager.create_address(user, attrs)

    assert address1.recipient == "John"
    assert address1.address_line_one == "777 Good st"
    assert address1.address_line_two == "APT 320"
    assert address1.business_name == "Good"
    assert address1.zipcode == "90099"
    assert address1.city == "Los Angeles"
    assert address1.state == "CA"
    assert address1.instructions == "instructions"
    assert address1.user_id == user.id
  end

  test "create multiple addresses", context do
    user = context[:user]

    attrs1 = %{
      recipient: "John",
      address_line_one: "777 Good st",
      address_line_two: "APT 320",
      business_name: "Good",
      zipcode: "90099",
      city: "Los Angeles",
      state: "CA",
      instructions: "instructions"
    }

    attrs2 = %{
      recipient: "John",
      address_line_one: "777 Good st",
      address_line_two: "APT 320",
      business_name: "Good",
      zipcode: "90099",
      city: "Los Angeles",
      state: "CA",
      instructions: "instructions"
    }

    {:ok, _address1} = AccountManager.create_address(user, attrs1)
    {:ok, _address2} = AccountManager.create_address(user, attrs2)

    # get user with preload addresses
    query = from u in User, where: u.id == ^user.id
    saved_user = Repo.one(query) |> Repo.preload(:addresses)

    assert is_list(saved_user.addresses)
    assert Enum.count(saved_user.addresses) == 2
  end

  # test "google_signin_from_mobile/3 create new user if none exist?", context do
  #  {:ok, user} =
  #    AccountManager.google_signin_from_mobile(
  #      "new_user@example.com",
  #      "John Doe",
  #      "https://photourl.com"
  #    )

  #  assert user.email == "new_user@example.com"
  #  assert user.profile.first_name == "John"
  #  assert user.profile.last_name == "Doe"
  #  assert user.profile.photo_url == "https://photourl.com"
  # end

  # test "google_signin_from_mobile/3 return existing user?", context do
  #  user = context[:user]
  #  # Trying to sign in with existing user
  #  {:ok, user} =
  #    AccountManager.google_signin_from_mobile(
  #      "test@example.com",
  #      "John Doe",
  #      "https://photourl.com"
  #    )

  #  assert user == user
  # end

  # test "google_signin_from_mobile/3 without display_name" do
  #  {:ok, user} =
  #    AccountManager.google_signin_from_mobile(
  #      "no_name@example.com",
  #      nil,
  #      "https://photourl.com"
  #    )

  #  assert user.email == "no_name@example.com"
  #  assert user.profile.first_name == nil
  #  assert user.profile.last_name == nil
  #  assert user.profile.photo_url == "https://photourl.com"
  # end
end
