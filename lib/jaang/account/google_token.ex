defmodule Jaang.Account.GoogleToken do
  use Joken.Config

  add_hook(JokenJwks, strategy: Jaang.Account.GoogleStrategy)

  def token_config() do
    #google_client_id = Application.get_env(:jaang, :google_client_id)
    google_client_id = System.get_env("GOOGLE_CLIENT_ID")

    IO.puts "Inspecting google client id"
    IO.inspect(google_client_id)
    # Validate from token
    default_claims()
    |> add_claim("iss", nil, &(&1 == "https://accounts.google.com"))
    |> add_claim("aud", nil, &(&1 == google_client_id))
  end
end
