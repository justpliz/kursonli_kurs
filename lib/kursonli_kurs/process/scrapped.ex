defmodule KursonliKurs.Process.Scrapped do
  alias KursonliKursWeb.GeneralHelper
  alias KursonliKurs.EtsStorage.ScrappedData

  def process() do
    :timer.sleep(1000)
    IO.inspect("process")

    try do
      IO.inspect("try")
      scraping()
      :timer.sleep(60 * 1000 * 10)

      process()
    rescue
      _ ->
        IO.inspect("rescue")
        :timer.sleep(3 * 1000 * 10)
        process()
    end
  end

  def scraping() do
    with {:ok, response} = Application.get_env(:kursonli_kurs, :scrapped) |> HTTPoison.get() do
      [usd_buy, eur_buy, rub_buy, _, _, _, _] =
        Regex.scan(~r/<td .+"buy .+">.+<\/td>/, response.body)
        |> Enum.map(fn [x] ->
          String.replace(x, ~r/(<td .+"buy .+">|<\/td>)/, "")
        end)

      [usd_sale, eur_sale, rub_sale, _, _, _, _] =
        Regex.scan(~r/<td .+"sell .+">.+<\/td>/, response.body)
        |> Enum.map(fn [x] ->
          String.replace(x, ~r/(<td .+"sell .+">|<\/td>)/, "")
        end)

      {usd_buy, usd_sale} = normalize_currency(usd_buy, usd_sale, 0.5)
      {eur_buy, eur_sale} = normalize_currency(eur_buy, eur_sale, 0.5)
      {rub_buy, rub_sale} = normalize_currency(rub_buy, rub_sale, 0.05)

      ScrappedData.insert("USD", usd_buy, usd_sale)
      ScrappedData.insert("EUR", eur_buy, eur_sale)
      ScrappedData.insert("RUB", rub_buy, rub_sale)
    end
  end

  defp normalize_currency(buy, sale, diff) do
    buy = Decimal.add(buy, "-#{diff}") |> Decimal.to_string() |> GeneralHelper.rounding_str()
    sale = Decimal.add(sale, "#{diff}") |> Decimal.to_string() |> GeneralHelper.rounding_str()
    {buy, sale}
  end
end
