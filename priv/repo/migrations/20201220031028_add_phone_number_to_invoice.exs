defmodule Jaang.Repo.Migrations.AddPhoneNumberToInvoice do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :phone_number, :string
    end
  end
end
