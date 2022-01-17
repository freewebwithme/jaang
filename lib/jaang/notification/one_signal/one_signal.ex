defmodule Jaang.Notification.OneSignal do
  def create_notification(heading, contents, user_id) when is_binary(user_id) do
    IO.puts("Sending notifications")

    ExSignal.create_notifications(%{
      "headings" => %{"en" => heading},
      "contents" => %{"en" => contents},
      "include_external_user_ids" => [user_id]
    })
  end

  def create_notification(heading, contents, user_id) when is_integer(user_id) do
    IO.puts("Sending notifications")
    user_id = Integer.to_string(user_id)

    ExSignal.create_notifications(%{
      "headings" => %{"en" => heading},
      "contents" => %{"en" => contents},
      "include_external_user_ids" => [user_id]
    })
  end
end
