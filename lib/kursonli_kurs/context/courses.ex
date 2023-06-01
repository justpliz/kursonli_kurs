defmodule KursonliKurs.Context.Courses do
  @moduledoc """
  Courses context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Currency, Course, Filial, Organization, Setting}
  alias KursonliKursWeb.GeneralHelper

  require Logger

  @type course :: Course.t()
  @type params :: Map.t()

  @doc false
  def get(opts \\ []) do
    Course
    |> filter_by(opts)
    |> get_currency
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    Course
    |> filter_by(opts)
    |> get_currency
    |> Repo.all()
  end

  @doc false
  def create(params) do
    %Course{}
    |> Course.changeset(params)
    |> Repo.insert()
  end

  @doc false
  def delete(course) do
    Repo.delete(course)
  end

  @doc false
  @spec update(course, params) :: {:ok, course} | {:error, Ecto.Changeset.t()}
  def update(course, params) do
    course
    |> Course.changeset(params)
    |> Repo.update()
  end

  @doc false
  def count(opts \\ []) do
    Course
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  @doc """
  get currency info from course.currency_id
  f15a0dae-37bf-4bb0-9099-f67bc76d20de -> %{name: "Американский доллар", short_name: "USD"}.
  """
  def get_currency(query) do
    c = from(c in Currency, select: c)
    from(query, preload: [currency: ^c])
  end

  @doc """
  Получает курсы всех филиалов данной организации(org_id) конкретной валюты(currency_id).
  """
  def get_all_courses_by_filial(org_id, currency_id) do
    from(
      org in Organization,
      where: org.id == ^org_id,
      join: filial in Filial,
      on: filial.organization_id == org.id,
      join: course in Course,
      on: course.filial_id == filial.id and course.currency_id == ^currency_id,
      select: course
    )
    |> Repo.all()
  end

  @doc """
  Получение списка курсов филиала по filial_id.
  """
  def get_courses_list_by_filial_id(filial_id) do
    from(
      c in Course,
      where: c.filial_id == ^filial_id,
      join: cr in Currency,
      on: cr.id == c.currency_id,
      order_by: [cr.id],
      select: %{
        course_id: c.id,
        currency_id: cr.id,
        currency_name: cr.name,
        currency_short_name: cr.short_name,
        sale: c.sale,
        buy: c.buy,
        date: c.date
      }
    )
    |> Repo.all()
  end

  @doc """
  Курсы(USD, EUR., RUB) филиалов с автообновлением.bitstring()
  """
  def get_courses_for_auto_update(types) do
    result =
      from(s in Setting,
        where:
          s.auto_update == true and s.visible_course_status == true and s.shedule_type in ^types,
        join: f in Filial,
        where: f.id == s.filial_id,
        join: c in Course,
        where: c.filial_id == f.id,
        join: cr in Currency,
        where:
          c.currency_id == cr.id and
            cr.short_name in ["USD", "EUR", "RUB"],
        select: c
      )
      |> Repo.all()
      |> Enum.group_by(& &1.filial_id)

    # Рассчет задержки в мс до следующего обновления.
    # Вход: count = 9(филиалов), Выход: 13_330(мс).
    # count * delay <= 120 sec.
    count = Enum.count(result)

    delay = Float.floor(120 / count * 10) * 100
    delay = trunc(round(delay))

    {result, delay}
  end

  @doc """
  Подготовка данных для отображения на главной странице
  """
  def get_filial_by_city(city_id) do
    Repo.all(
      from f in Filial,
        where: f.city_id == ^city_id and f.filial_active_status == :active,
        join: s in Setting,
        on: s.filial_id == f.id and s.visible_course_status == true,
        join: org in Organization,
        on: org.id == f.organization_id,
        left_join: c in assoc(f, :course),
        where: not is_nil(c.id),
        left_join: cr in assoc(c, :currency),
        preload: [course: {c, currency: cr}],
        select: %{
          filial: f,
          setting: %{
            tags: s.tags,
            phones: s.phones,
            promo: s.promo,
            visible_website_status: s.visible_website_status,
            address: s.address,
            link: s.link,
            logo: s.logo,
            slug: s.slug,
            url: s.url,
            color_logo: s.colors["color_logo"]
          }
        }
    )
    |> Enum.map(
      &%{
        setting: ensure_default_logo(&1.setting),
        course: &1.filial.course,
        filial_id: &1.filial.id,
        address: &1.setting.address,
        filial_name: &1.filial.name,
        first_letter: &1.filial.name |> String.trim() |> String.first() |> String.upcase()
      }
    )
    |> ensure_date()
    # |> ensure_srapped_diapason
    |> Enum.sort_by(& &1.date, {:desc, NaiveDateTime})
  end

  # Проверка на наличие дефолтного лого филиала
  defp ensure_default_logo(setting) do
    if setting.logo != "images/logo/default_logo.jpg",
      do: setting,
      else: Map.put(setting, :logo, nil)
  end

  def ensure_date(filials) do
    Enum.map(filials, fn filial ->
      last_updated_course = Enum.max_by(filial.course, & &1.date)

      filial
      |> Map.put(:date, last_updated_course.date)
      |> Map.put(:date_h, GeneralHelper.date_to_hour(last_updated_course.date))
      |> Map.put(:date_m, GeneralHelper.date_to_minute(last_updated_course.date))
      |> Map.put(:date_s, GeneralHelper.date_to_second(last_updated_course.date))
      |> Map.put(:humanizated_date, GeneralHelper.humanizated_date(last_updated_course.date))
    end)
  end

  alias KursonliKurs.EtsStorage.ScrappedData

  # Проверяет находятся ли все валюты(usd, eur, rub) в дапазоне scrapped
  # Если нет, то в reduce НЕ добавляем такие обменные пункты
  defp ensure_srapped_diapason(courses) do
    [usd, eur, rub] =
      ScrappedData.get_all()
      |> Enum.map(fn [_currency, buy, sale] ->
        {buy, ""} = buy |> Float.parse()
        {sale, ""} = sale |> Float.parse()
        [buy, sale]
      end)

    [usd_buy, usd_sale] = usd
    [eur_buy, eur_sale] = eur
    [rub_buy, rub_sale] = rub

    courses
    |> Enum.reduce(
      [],
      fn map, acc ->
        usd = Enum.find(map.course, &(&1.short_name == "USD"))

        usd_range =
          if is_nil(usd), do: true, else: value_in_range?(usd.buy, usd.sale, usd_buy, usd_sale)

        eur = Enum.find(map.course, &(&1.short_name == "EUR"))

        eur_range =
          if is_nil(eur), do: true, else: value_in_range?(eur.buy, eur.sale, eur_buy, eur_sale)

        rub = Enum.find(map.course, &(&1.short_name == "RUB"))

        rub_range =
          if is_nil(rub), do: true, else: value_in_range?(rub.buy, rub.sale, rub_buy, rub_sale)

        is_range = usd_range && eur_range && rub_range
        if is_range, do: acc ++ [map], else: acc
      end
    )
  end

  # Возвращает true если значение курса входит в диапазон scrapped
  defp value_in_range?("-", _buy, _scrapped_buy, _scrapped_sale), do: false
  defp value_in_range?(_sale, "-", _scrapped_buy, _scrapped_sale), do: false

  defp value_in_range?(sale, buy, scrapped_buy, scrapped_sale) do
    {sale, ""} = sale |> Float.parse()
    {buy, ""} = buy |> Float.parse()

    if sale > scrapped_buy and sale < scrapped_sale and
         buy > scrapped_buy and buy < scrapped_sale do
      true
    else
      false
    end
  end

  # Все курсы одной валюты(short_name) в городе(city_id)
  def get_all_courses_of_one_currency(short_name, city_id) do
    from(
      f in Filial,
      where: f.city_id == ^city_id,
      join: s in Setting,
      where: s.visible_course_status == true and s.filial_id == f.id,
      join: cr in Currency,
      where: cr.short_name == ^short_name,
      join: c in Course,
      where: c.filial_id == f.id and c.currency_id == cr.id,
      select: %{
        filial_id: c.filial_id,
        buy: c.buy,
        sale: c.sale
      }
    )
    |> Repo.all()
    |> find_best_courses
  end

  defp find_best_courses(courses) do
    float_courses =
      Enum.map(courses, fn course ->
        course
        |> Map.put(:buy, GeneralHelper.string_to_float(course.buy) |> String.to_float())
        |> Map.put(:sale, GeneralHelper.string_to_float(course.sale) |> String.to_float())
      end)

    max_buy = Enum.max_by(float_courses, & &1.buy) |> Map.get(:buy)

    max_ids =
      float_courses
      |> Enum.filter(fn %{buy: buy} -> buy == max_buy end)
      |> Enum.map(fn %{filial_id: id} -> id end)

    min_sale = Enum.min_by(float_courses, & &1.sale) |> Map.get(:sale)

    min_ids =
      float_courses
      |> Enum.filter(fn %{sale: sale} -> sale == min_sale end)
      |> Enum.map(fn %{filial_id: id} -> id end)

    {courses, max_ids, min_ids}
  end
end
