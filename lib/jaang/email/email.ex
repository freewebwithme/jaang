defmodule Jaang.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: JaangWeb.EmailView

  # TODO: Edit it later
  def welcome_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Welcome to Jaang")
    |> assign(:user, user)
    |> render(:welcome_email)
  end

  def reset_password_email(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Password Reset")
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:password_reset)
  end

  def confirmation_instructions(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Confirm your email")
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:confirm_email)
  end

  def update_email_instructions(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Update your email")
    |> assign(:user, user)
    |> assign(:url, url)
    |> render(:update_email)
  end

  defp base_email() do
    new_email()
    |> from("jaang@example.com")
    |> put_header("Reply-to", "jaang@example.com")
  end
end
