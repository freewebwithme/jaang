defmodule JaangWeb.Admin.Helpers do
  alias Jaang.Utility

  @doc """
  Pick first product image from list of product images
  """
  def pick_product_image(product_images) do
    [first_image] = Enum.filter(product_images, &(&1.order == 1))
    first_image.image_url
  end

  def display_fullname(first, last) when is_binary(first) and is_binary(last) do
    first <> " " <> last
  end

  def display_fullname(first, last) when is_binary(first) and is_nil(last) do
    first
  end

  def display_fullname(first, last) when is_nil(first) and is_binary(last) do
    last
  end

  def display_fullname(first, last) when is_nil(first) and is_nil(last) do
    "No name"
  end

  def display_money(money) when is_nil(money) do
    "Not yet calculated"
  end

  def display_money(money) when is_binary(money) do
    money
  end

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

  def display_address(addresses) when is_list(addresses) do
    if Enum.count(addresses) == 0 do
      nil
    else
      [address] = Enum.filter(addresses, & &1.default)
      address.address_line_one
    end
  end

  @doc """
  convert and format datetime
  param: ~N , naive datetime
  returns: "Nov 19, 2020 5:07 PM"
  """
  def display_datetime(datetime) do
    if datetime == nil do
      "No date and time specified"
    else
      {:ok, formatted_datetime} = Utility.convert_and_format_datetime(datetime)
      formatted_datetime
    end
  end

  def display_user_avatar(imageUrl) when is_nil(imageUrl) do
    "https://jaang-la.s3-us-west-1.amazonaws.com/default-avatar.jpg"
  end

  def display_user_avatar(imageUrl) do
    imageUrl
  end
end
