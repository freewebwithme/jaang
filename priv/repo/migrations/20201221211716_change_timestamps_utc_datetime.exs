defmodule Jaang.Repo.Migrations.ChangeTimestampsUtcDatetime do
  use Ecto.Migration

  def change do
    alter table("addresses") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("profiles") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("users") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime
      remove :confirmed_at, :naive_datetime
      add :confirmed_at, :timestamptz

      timestamps(type: :timestamptz)
    end

    alter table("categories") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("product_images") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("product_recipe_tags") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("product_tags") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("products") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("recipe_tags") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("tags") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("units") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end

    alter table("stores") do
      remove :inserted_at, :naive_datetime
      remove :updated_at, :naive_datetime

      timestamps(type: :timestamptz)
    end
  end
end
