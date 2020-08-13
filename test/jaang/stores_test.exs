defmodule Jaang.StoresTest do
  use Jaang.DataCase, async: true

  alias Jaang.Store
  alias Jaang.Store.Stores

  test "store is created with information correctly" do
    {:ok, store} =
      Stores.create_store(%{
        name: "Store1",
        description: "description",
        price_info: "price info",
        available_hours: "available hours"
      })

    assert store.name == "Store1"
    assert store.description == "description"
    assert store.price_info == "price info"
    assert store.available_hours == "available hours"
  end
end
