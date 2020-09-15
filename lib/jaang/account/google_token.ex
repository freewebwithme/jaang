defmodule Jaang.Account.GoogleToken do
  use Joken.Config

  add_hook(JokenJwks, strategy: Jaang.Account.GoogleStrategy)

  def token_config do
    auds = [
      "345346706154-um2qid7ticiu01sh9cloi7mvvhgcq5eu.apps.googleusercontent.com",
      "345346706154-832qu1hd0q9e6rupbdn5ql0jeeg334vk.apps.googleusercontent.com",
      "345346706154-rhmg33nug4hvhb10c53krflrj8k9hllg.apps.googleusercontent.com",
      "345346706154-057lmqcipbrco38l21m53qg82l5m4evv.apps.googleusercontent.com"
    ]

    # Validate from the token
    default_claims()
    |> add_claim("iss", nil, &(&1 == "https://accounts.google.com"))
    |> add_claim(
      "aud",
      nil,
      &Enum.member?(auds, &1)
    )
  end
end
