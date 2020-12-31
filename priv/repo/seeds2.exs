alias Jaang.Product.ProductPrice

@timezone "America/Los_Angeles"

attrs = %{
  on_sale: true,
  start_date: Timex.to_datetime({{2020, 12, 30}, {0, 0, 0}}, @timezone),
  end_date: Timex.to_datetime({{2020, 12, 31}, {19, 0, 0}}, @timezone)
}
