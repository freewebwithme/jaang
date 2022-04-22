defmodule Jaang.Utility do
  alias Jaang.{Repo, Store, Category}
  alias Jaang.Category.SubCategory
  alias Jaang.Product.{Products}

  @doc """
  convert and format datetime
  param: ~N , naive datetime
  returns: {:ok, "Nov 19, 2020 5:07 PM"}
  """
  def convert_and_format_datetime(datetime) do
    Timex.to_datetime(datetime, "America/Los_Angeles")
    |> Timex.format("{Mshort} {D}, {YYYY} {h12}:{m} {AM}")
  end

  @doc """
  Convert string key to atom key in map
  """
  def convert_string_key_to_atom_key(attrs) do
    for {key, value} <- attrs, into: %{}, do: {String.to_atom(key), value}
  end

  @doc """
  [
    {
      "keyId" => "34"
    }
  ]
  to
  [
    {
      key_id: 34
    }
  ]
  """
  def convert_map_to_atom_key_map(maps) do
    Enum.map(maps, fn map ->
      Map.new(map, fn {k, v} ->
        {Macro.underscore(k) |> String.to_atom(), v}
      end)
    end)
  end

  @doc """
  Price compare
  params:
  old_price = %MarketPrice{}
  new_price = %Money{}
  """
  def price_changed?(old_price, new_price) do
    price_changed =
      cond do
        old_price.on_sale == true ->
          if Money.compare(new_price, old_price.sale_price) == 0 do
            false
          else
            true
          end

        old_price.on_sale == false ->
          if Money.compare(new_price, old_price.original_price) == 0 do
            false
          else
            true
          end

        true ->
          false
      end

    price_changed
  end

  @doc """
  Check if date is today.
  This function is called for checking invoice.delivery_date is Today
  """
  def today?(date) do
    Timex.today() == date
  end

  def get_product_info_from_xlsx(path) do
    {:ok, table_ref} = Xlsxir.extract(path, 0)
    products_list = Xlsxir.get_list(table_ref)
    [_field_name | product_infos] = products_list
    # Get all stores
    stores = Repo.all(Store)
    categories = Repo.all(Category)
    sub_categories = Repo.all(SubCategory)

    Enum.map(product_infos, fn info ->

      [
        product_name,
        product_image_1,
        product_image_2,
        product_image_3,
        published,
        barcode,
        unit_name,
        store_name,
        category_name,
        sub_category_name,
        weight_based,
        tags,
        recipe_tags,
        market_price,
        description,
        ingredients,
        directions,
        warnings,
        vendor
      ] = info

      # Get selected store
      [store] =
        Enum.filter(stores, fn store ->
          String.downcase(store.name)
          |> String.contains?(store_name)
        end)

      [category] =
        Enum.filter(categories, fn category ->
          String.downcase(category.name)
          |> String.contains?(category_name)
        end)

      [sub_category] =
        Enum.filter(sub_categories, fn sub_category ->
          String.downcase(sub_category.name)
          |> String.contains?(sub_category_name)
        end)

      product_attrs = %{
        name: product_name,
        description: description,
        ingredients: ingredients,
        directions: directions,
        warnings: warnings,
        published: published,
        barcode: Integer.to_string(barcode),
        unit_name: unit_name,
        weight_based: weight_based,
        store_name: String.capitalize(store_name),
        store_id: store.id,
        category_name: category_name,
        category_id: category.id,
        sub_category_name: sub_category_name,
        sub_category_id: sub_category.id,
        original_price: market_price,
        tags: tags,
        recipe_tags: recipe_tags,
        vendor: vendor
      }

      product = Products.create_product(product_attrs)
      # Build product images
      if product_image_1 != nil do
        image_url_1 = build_s3_url(product_image_1)
        Products.create_product_image(product, %{image_url: image_url_1, order: 1})
      end

      if product_image_2 != nil do
        image_url_2 = build_s3_url(product_image_2)
        Products.create_product_image(product, %{image_url: image_url_2, order: 2})
      end

      if product_image_3 != nil do
        image_url_3 = build_s3_url(product_image_3)
        Products.create_product_image(product, %{image_url: image_url_3, order: 3})
      end
    end)
  end

  def build_s3_url(image_file_name) when is_binary(image_file_name) do
    bucket_name = System.get_env("AWS_BUCKET_NAME")
    region = System.get_env("AWS_REGION")
    "https://#{bucket_name}.s3-#{region}.amazonaws.com/product-images/#{image_file_name}"
  end

  def build_s3_url(_image_file_name), do: nil

  @doc """
  Traverses the changeset errors and returns a map of
  error messages. For example:

  %{start_date: ["can't be blank"], end_date: ["can't be blank"]}
  """
  def error_details(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
