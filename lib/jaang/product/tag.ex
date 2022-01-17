defmodule Jaang.Product.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jaang.Repo
  import Ecto.Query

  schema "tags" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> unique_constraint(:name)
    |> validate_required([:name])
  end

  def parse_tags(attrs) do
    (Map.get(attrs, :tags) || Map.get(attrs, "tags") || "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all()
  end

  # put_assoc is used when I have already an associated struct so
  # before use put_assoc, do create a database record
  defp insert_and_get_all([]), do: []

  defp insert_and_get_all(names) do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second)
    maps = Enum.map(names, &%{name: &1, inserted_at: timestamp, updated_at: timestamp})
    Repo.insert_all(Jaang.Product.Tag, maps, on_conflict: :nothing)
    Repo.all(from(t in Jaang.Product.Tag, where: t.name in ^names))
  end
end
