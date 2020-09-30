defmodule Jaang.Repo.Migrations.AddPhotoUrlToProfile do
  use Ecto.Migration

  def change do
    alter table("profiles") do
      add :photo_url, :string
    end
  end
end
