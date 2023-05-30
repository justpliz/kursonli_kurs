defmodule KursonliKurs.Process.AutoUpdate do
  alias KursonliKurs.Context.{Courses}
  alias KursonliKurs.EtsStorage.ScrappedData

  require Logger

  def process() do
    IO.inspect("process")
    :timer.sleep(10 * 1000)

    # Значения "лучших курсов".
    scrapped_courses = ScrappedData.get_all()

    process(scrapped_courses)
  end

  def process(scrapped_courses) do
    IO.inspect("process with scrapped_courses")
    types = define_opts()

    # Группируем курсы("USD", "EUR", "RUB") по filial_id.
    {courses, delay} = Courses.get_courses_for_auto_update(types)
    new_courses = ScrappedData.get_all()

    # Проверка на изменение курсов МИГа
    if scrapped_courses != new_courses, do: update_all_courses_now(courses, new_courses)

    try do
      # Обновление 3 основных курсов каждого из филиалов по очереди с задержкой.
      Enum.map(courses, fn {_filial_id, filial_courses} ->
        auto_update_for_one_filial(filial_courses, new_courses)

        :timer.sleep(delay)
      end)

      :timer.sleep(1000)
      process(new_courses)
    rescue
      _ ->
        :timer.sleep(10 * 1000)
        process()
    end
  end

  # Определение типа графика работы для автообновления и времени до изменения типа.
  defp define_opts() do
    now = Timex.now("Asia/Almaty")
    today_9 = Timex.set(now, hour: 9, minute: 00, second: 00)
    today_20 = Timex.set(now, hour: 20, minute: 00, second: 00)
    today_22 = Timex.set(now, hour: 22, minute: 00, second: 00)
    # tommorow9 = Timex.shift(today_9, days: 1)

    # В период с 9 до 20, входят и остальные.
    cond do
      Timex.between?(now, today_9, today_20) -> [:nine_twenty, :nine_twenty_two, :full]
      Timex.between?(now, today_20, today_22) -> [:nine_twenty_two, :full]
      Timex.before?(now, today_9) or Timex.after?(now, today_22) -> [:full]
      true -> []
    end

    # next_try =
    #   case types do
    #     :nine_twenty -> Timex.diff(today_20, now)
    #     :nine_twenty_two -> Timex.diff(today_22, now)
    #     :full -> Timex.diff(tommorow9, now, :milliseconds)
    #   end
  end

  # Обновление 3 основных курсов одного филиала.
  defp auto_update_for_one_filial(filial_courses, scrapped_courses) do
    [["USD", usd_buy, usd_sale], ["EUR", eur_buy, eur_sale], ["RUB", rub_buy, rub_sale]] =
      scrapped_courses

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

  # Изменение сразу всех курсов для того чтобы
  defp update_all_courses_now(courses, new_courses) do
    [["USD", usd_buy, usd_sale], ["EUR", eur_buy, eur_sale], ["RUB", rub_buy, rub_sale]] =
      new_courses

      Enum.map(courses, fn course ->
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

    process()
  end
end
