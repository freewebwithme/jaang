defmodule JaangWeb.Admin.Helpers do
  def display_money(%Money{} = money) do
    Money.to_string(money)
  end

  def capitalize_text(text) do
    text = Atom.to_string(text)
    String.capitalize(text, :default)
  end

  def has_next_page?(num_of_result, per_page) do
    if num_of_result < per_page do
      false
    else
      true
    end
  end
end
