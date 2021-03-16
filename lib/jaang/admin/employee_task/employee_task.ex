defmodule Jaang.Admin.EmployeeTask do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias Jaang.Checkout.LineItem

  schema "employee_tasks" do
    field :task_type, Ecto.Enum, values: [:shopping, :delivery]
    field :task_status, Ecto.Enum, values: [:in_progress, :done]
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :duration, :integer
    field :invoice_id, :id
    field :order_id, :id

    embeds_many :line_items, LineItem, on_replace: :delete
    belongs_to :employee, Jaang.Admin.Account.Employee.Employee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%EmployeeTask{} = employee_task, attrs) do
    fields = [
      :task_type,
      :task_status,
      :start_datetime,
      :end_datetime,
      :duration,
      :invoice_id,
      :order_id,
      :employee_id
    ]

    required_fields = [
      :task_type,
      :task_status,
      :start_datetime,
      :invoice_id,
      :order_id,
      :employee_id
    ]

    line_items = Map.get(attrs, :line_items)

    # Convert %LineItem{} to map %{}
    attrs =
      if line_items do
        line_items = Enum.map(line_items, &Map.from_struct/1)
        Map.put(attrs, :line_items, line_items)
      else
        attrs
      end

    employee_task
    |> cast(attrs, fields)
    |> validate_required(required_fields)
    |> cast_embed(:line_items, required: true, with: &LineItem.changeset/2)
  end
end
