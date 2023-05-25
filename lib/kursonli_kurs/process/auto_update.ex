defmodule KursonliKurs.Process.AutoUpdate do
  alias KursonliKurs.Context.{Settings, Courses}
  alias KursonliKurs.EtsStorage.ScrappedData

  require Logger

  def process() do
    :timer.sleep(10 * 1000)

    # Группируем курсы("USD", "EUR", "RUB") по filial_id.
    courses = Courses.get_courses_for_auto_update()

    # Колличество филилов с автообновлением
    count = Settings.count(%{auto_update: true})

    # Время до следующего обновления в миллисекундах.
    delay = calculate_delay(count)

    # Значения "лучших курсов".
    scrapped_courses = ScrappedData.get_all()

    try do
      # Обновление 3 основных курсов каждого из филиалов по очереди с задержкой.
      Enum.map(courses, fn {_filial_id, filial_courses} ->
        auto_update_for_one_filial(filial_courses, scrapped_courses)

        :timer.sleep(delay)
      end)

      process()
    rescue
      _ ->
        :timer.sleep(110 * 1000)
        process()
    end
  end

  # Рассчет задержки в мс до следующего обновления.
  # Вход: count = 9(филиалов), Выход: 13_330(мс).
  # count * delay <= 120 sec.
  defp calculate_delay(count) do
    delay = Float.floor(120 / count * 10) * 100
    trunc(round(delay))
  end

  # Обновление 3 основных курсов одного филиала.
  defp auto_update_for_one_filial(filial_courses, scrapped_courses) do
    [["USD", usd_buy, usd_sale], ["EUR", eur_buy, eur_sale], ["RUB", rub_buy, rub_sale]] = scrapped_courses

      Enum.map(filial_courses, fn course ->
        case course.currency_id do
          1 ->
            Courses.update(course, %{
              buy: usd_buy,
              sale: usd_sale,
              date: Timex.now("Asia/Almaty")
            })

          2 ->
            Courses.update(course, %{
              buy: eur_buy,
              sale: eur_sale,
              date: Timex.now("Asia/Almaty")
            })

          3 ->
            Courses.update(course, %{
              buy: rub_buy,
              sale: rub_sale,
              date: Timex.now("Asia/Almaty")
            })

          _any ->
            nil
        end
      end)
  end
end
