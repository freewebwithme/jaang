defmodule JaangWeb.Admin.Helpers do
  alias Jaang.Utility

  def display_money(%Money{} = money) do
    Money.to_string(money)
  end

  def display_phone_number(phone_number) when is_binary(phone_number) do
    area_code = String.slice(phone_number, 0, 3)
    first_three = String.slice(phone_number, 3, 3)
    last_four = String.slice(phone_number, 6, 4)
    "(#{area_code})#{first_three}-#{last_four}"
  end

  def display_phone_number(phone_number) when is_nil(phone_number), do: nil

  def capitalize_text(text) when is_atom(text) do
    text = Atom.to_string(text)
    String.capitalize(text, :default)
  end

  def capitalize_text(text) when is_binary(text) do
    String.capitalize(text, :default)
  end

  def uppercase_text(text) when is_binary(text) do
    String.upcase(text)
  end

  def uppercase_text(text) when is_nil(text), do: nil

  @doc """
  Convert atom to string or string to atom depends on argument
  """
  def convert_atom_and_string(text) when is_atom(text) do
    Atom.to_string(text) |> String.capitalize()
  end

  def convert_atom_and_string(text) when is_binary(text) do
    String.downcase(text) |> String.to_atom()
  end

  def convert_atom_and_string(text) when is_nil(text), do: nil

  def has_next_page?(num_of_result, per_page) do
    if num_of_result < per_page do
      false
    else
      true
    end
  end

  @doc """
  convert and format datetime
  param: ~N , naive datetime
  returns: "Nov 19, 2020 5:07 PM"
  """
  def display_datetime(datetime) do
    {:ok, formatted_datetime} = Utility.convert_and_format_datetime(datetime)
    formatted_datetime
  end
end
