defmodule KursonliKurs.Process.Scrapped do
  alias KursonliKursWeb.GeneralHelper
  alias KursonliKurs.EtsStorage.ScrappedData
  @scrapped_period Application.get_env(:kursonli_kurs, :scrapped_period)

  require Logger

  def process() do
    :timer.sleep(1000)

    try do
      scraping()
      :timer.sleep(@scrapped_period)

      process()
    rescue
      _ ->
        :timer.sleep(@scrapped_period)
        process()
    end
  end

  # Парсинг значений курсов с "https://mig.kz/"
  def scraping() do
    url = Application.get_env(:kursonli_kurs, :scrapped)

    with {:ok, response} <- HTTPoison.get(url) do
      # Выборка значений покупки
      [usd_buy, eur_buy, rub_buy, _, _, _, _] =
        Regex.scan(~r/<td .+"buy .+">.+<\/td>/, response.body)
        |> Enum.map(fn [x] ->
          String.replace(x, ~r/(<td .+"buy .+">|<\/td>)/, "")
        end)

      # Выборка значений продажи
      [usd_sale, eur_sale, rub_sale, _, _, _, _] =
        Regex.scan(~r/<td .+"sell .+">.+<\/td>/, response.body)
        |> Enum.map(fn [x] ->
          String.replace(x, ~r/(<td .+"sell .+">|<\/td>)/, "")
        end)

      {usd_buy, usd_sale} = normalize_currency(usd_buy, usd_sale, 0.5)
      {eur_buy, eur_sale} = normalize_currency(eur_buy, eur_sale, 0.5)
      {rub_buy, rub_sale} = normalize_currency(rub_buy, rub_sale, 0.05)

      # Запись в ETS.
      ScrappedData.insert("USD", usd_buy, usd_sale)
      ScrappedData.insert("EUR", eur_buy, eur_sale)
      ScrappedData.insert("RUB", rub_buy, rub_sale)
    end
  end

  # Поправка курса на значение diff
  defp normalize_currency(buy, sale, diff) do
    buy = Decimal.add(buy, "-#{diff}") |> Decimal.to_string() |> GeneralHelper.rounding_str()
    sale = Decimal.add(sale, "#{diff}") |> Decimal.to_string() |> GeneralHelper.rounding_str()
    {buy, sale}
  end
end
