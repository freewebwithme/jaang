defmodule Jaang.CustomerServicesTest do
  use Jaang.DataCase

  alias Jaang.CustomerServices

  describe "customer_messages" do
    alias Jaang.CustomerServices.CustomerMessage

    import Jaang.CustomerServicesFixtures

    @invalid_attrs %{message: nil, status: nil}

    test "list_customer_messages/0 returns all customer_messages" do
      customer_message = customer_message_fixture()
      assert CustomerServices.list_customer_messages() == [customer_message]
    end

    test "get_customer_message!/1 returns the customer_message with given id" do
      customer_message = customer_message_fixture()
      assert CustomerServices.get_customer_message!(customer_message.id) == customer_message
    end

    test "create_customer_message/1 with valid data creates a customer_message" do
      valid_attrs = %{message: "some message", status: "some status"}

      assert {:ok, %CustomerMessage{} = customer_message} = CustomerServices.create_customer_message(valid_attrs)
      assert customer_message.message == "some message"
      assert customer_message.status == "some status"
    end

    test "create_customer_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CustomerServices.create_customer_message(@invalid_attrs)
    end

    test "update_customer_message/2 with valid data updates the customer_message" do
      customer_message = customer_message_fixture()
      update_attrs = %{message: "some updated message", status: "some updated status"}

      assert {:ok, %CustomerMessage{} = customer_message} = CustomerServices.update_customer_message(customer_message, update_attrs)
      assert customer_message.message == "some updated message"
      assert customer_message.status == "some updated status"
    end

    test "update_customer_message/2 with invalid data returns error changeset" do
      customer_message = customer_message_fixture()
      assert {:error, %Ecto.Changeset{}} = CustomerServices.update_customer_message(customer_message, @invalid_attrs)
      assert customer_message == CustomerServices.get_customer_message!(customer_message.id)
    end

    test "delete_customer_message/1 deletes the customer_message" do
      customer_message = customer_message_fixture()
      assert {:ok, %CustomerMessage{}} = CustomerServices.delete_customer_message(customer_message)
      assert_raise Ecto.NoResultsError, fn -> CustomerServices.get_customer_message!(customer_message.id) end
    end

    test "change_customer_message/1 returns a customer_message changeset" do
      customer_message = customer_message_fixture()
      assert %Ecto.Changeset{} = CustomerServices.change_customer_message(customer_message)
    end
  end
end
