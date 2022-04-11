defmodule Jaang.EmailManager do
  alias Jaang.{Email, Mailer}

  def send_welcome_email(user) do
    Email.welcome_email(user)
    |> Mailer.deliver_later!()
  end

  def send_reset_password_email(user, url) do
    Email.reset_password_email(user, url)
    |> Mailer.deliver_later!()
  end

  def send_confirmation_instructions(user, url) do
    Email.confirmation_instructions(user, url)
    |> Mailer.deliver_later!()
  end

  def send_update_email_instructions(user, url) do
    Email.update_email_instructions(user, url)
    |> Mailer.deliver_later!()
  end
end
