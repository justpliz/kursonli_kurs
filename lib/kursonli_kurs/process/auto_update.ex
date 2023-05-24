defmodule KursonliKurs.Process.AutoUpdate do
  # alias KursonliKurs.Context.{Settings, Filials, Courses}
  alias KursonliKurs.Context.{Courses}
  alias KursonliKurs.EtsStorage.ScrappedData

  require Logger

  def process() do
    :timer.sleep(10 * 1000)
    IO.inspect(label: "process")

    courses = Courses.get_courses_for_auto_update()
    count = Enum.count(courses)

    # Время до следующего обновления в миллисекундах
    delay = Float.floor(120 / count * 10) * 100
    delay = trunc(round(delay))

    [["USD", usd_buy, usd_sale], ["EUR", eur_buy, eur_sale], ["RUB", rub_buy, rub_sale]] =
      ScrappedData.get_all()

    try do
      Enum.map(courses, fn {_id, filail} ->
        Enum.map(filail, fn course ->
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

        :timer.sleep(delay)
      end)

      process()
    rescue
      _ ->
        IO.inspect(label: "rescue")
        :timer.sleep(1000)
        process()
    end
  end
end
