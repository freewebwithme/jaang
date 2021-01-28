### Create random user
first_names = ["David", "James", "Tom", "John", "Yoonseo", "Rang", "Jihye", "Taehwan"]
last_names = ["Kim", "Lee", "Park", "Bak", "Song", "Cho", "Choi"]

for x <- 0..9 do
  attrs = %{
    email: "user#{x}@example.com",
    password: "supersupersecret",
    password_confirmation: "supersupersecret",
    profile: %{
      first_name: Enum.random(first_names),
      last_name: Enum.random(last_names),
      phone: "2134445555"
    }
  }

  Jaang.Account.Accounts.create_user_with_profile(attrs)
end
