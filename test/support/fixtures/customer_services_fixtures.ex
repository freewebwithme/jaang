defmodule Jaang.CustomerServicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jaang.CustomerServices` context.
  """

  @doc """
  Generate a customer_message.
  """
  def customer_message_fixture(attrs \\ %{}) do
    {:ok, customer_message} =
      attrs
      |> Enum.into(%{
        message: "some message",
        status: "some status"
      })
      |> Jaang.Admin.CustomerServices.create_customer_message()

    customer_message
  end
end
