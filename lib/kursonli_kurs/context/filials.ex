defmodule KursonliKurs.Context.Filials do
  @moduledoc """
  Filials context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{
    Filial,
    City,
    Organization,
    Tariff,
    Currency,
    Setting,
    Course,
    Worker,
    FilialCurrency,
    Currency
  }

  alias KursonliKurs.Context.{Filials, Workers, Settings, Cities}
  alias KursonliKursWeb.GeneralHelper
  alias KursonliKurs.EtsStorage.ScrappedData

  require Logger

  @type filial :: Filial.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Cities.get_city_name()
    |> Repo.one()
  end

  def all(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Filial{}
    |> Filial.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(filial, params) :: {:ok, filial} | {:error, Ecto.Changeset.t()}
  def update(filial, params) do
    filial
    |> Filial.changeset(params)
    |> Repo.update()
  end

  def count(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  @doc """
  get filial info from filail_id
  """
  def get_filail_name(query) do
    f = from(f in Filial, select: %{name: f.name})
    from(query, preload: [filial: ^f])
  end

  def create_filial_worker_setting(filial_opts, worker_opts) do
    with {:ok, filial} <- Filials.create(filial_opts),
         worker_opts <- Map.put(worker_opts, :filial_id, filial.id),
         {:ok, _worker} <- Workers.create(worker_opts),
         {:ok, _setting} <- Settings.create(%{filial_id: filial.id}) do
      {:ok, filial}
    end
  end

  def filial_list() do
    from(
      filial in Filial,
      join: city in City,
      on: filial.city_id == city.id,
      join: org in Organization,
      on: filial.organization_id == org.id,
      join: setting in Setting,
      on: setting.filial_id == filial.id,
      join: worker in Worker,
      on: worker.filial_id == filial.id,
      left_join: tariff in Tariff,
      on: filial.tariff_id == tariff.id,
      select: %{
        id: filial.id,
        filial_name: filial.name,
        filial_active_status: filial.filial_active_status,
        paid_up_to: filial.paid_up_to,
        org_name: org.name,
        city_name: city.name,
        city_id: city.id,
        tariff_name: tariff.name,
        tariff_price: tariff.price,
        coordinates: setting.coordinates,
        firm_id: setting.firm_id,
        email: worker.email
      }
    )
    |> Repo.all()
  end

  def get_courses_list(filial_id) do
    from(
      # filial in Filial,
      # where: filial.id == ^filial_id,
      # join: course in Course,
      # on: course.filial_id == filial.id,
      # join: c in Currency,
      # on: c.id == course.currency_id,
      fc in FilialCurrency,
      where: fc.filial_id == ^filial_id,
      join: course in Course,
      on: course.currency_id == fc.currency_id and course.filial_id == fc.filial_id,
      join: c in Currency,
      on: c.id == fc.currency_id,
      order_by: [c.id],
      select: %{
        currency_id: c.id,
        course_id: course.id,
        currency_name: c.name,
        currency_short_name: c.short_name,
        value_for_sale: course.value_for_sale,
        value_for_purchase: course.value_for_purchase,
        date: course.date
      }
    )
    |> Repo.all()
  end

  def get_city_by_filial_id(filial_id) do
    from(
      filial in Filial,
      where: filial.id == ^filial_id,
      join: city in City,
      on: filial.city_id == city.id,
      select: %{name: city.name, eng_name: city.eng_name}
    )
    |> Repo.one()
  end

  def get_last_date_for_course(filial_id) do
    Repo.one(
      from(
        filial in Filial,
        where: filial.id == ^filial_id,
        join: course in Course,
        on: course.filial_id == filial.id,
        order_by: [desc: course.date],
        limit: 1,
        select: course.date
      )
    )
  end

  def get_filial_by_city(city_id) do
    Repo.all(
      from f in Filial,
        where:
          f.city_id == ^city_id and f.filial_active_status == :active and
            f.visible_course_status == true,
        left_join: s in Setting,
        on: s.filial_id == f.id,
        join: org in Organization,
        on: org.id == f.organization_id,
        left_join: c in assoc(f, :course),
        left_join: cr in assoc(c, :currency),
        preload: [course: {c, currency: cr}],
        select: %{
          filial: f,
          setting: %{
            tags: s.tags,
            phones: s.phones,
            promo: s.promo,
            visible_website_status: s.visible_website_status,
            logo: s.logo,
            color_logo: s.colors["color_logo"]
          }
        }
    )
    |> Enum.map(
      &%{
        setting: ensure_default_logo(&1.setting),
        course: course_handler(&1.filial.course),
        filial_id: &1.filial.id,
        filial_address: &1.filial.filial_address,
        filial_name: &1.filial.name,
        date: hd(&1.filial.course).date,
        date_h: GeneralHelper.date_to_string_time_h(hd(&1.filial.course).date),
        date_m: GeneralHelper.date_to_string_time_m(hd(&1.filial.course).date),
        date_s: GeneralHelper.date_to_string_time_s(hd(&1.filial.course).date),
        humanizated_date: GeneralHelper.humanizated_date(hd(&1.filial.course).date),
        first_letter: &1.filial.name |> String.trim() |> String.first() |> String.upcase()
      }
    )
    |> ensure_srapped_diapason()

    # |> Enum.sort_by(& &1.date, :desc)
    |> Enum.sort_by(& &1.date, {:desc, Date})
  end

  # Добавляет флаги для отображения лучшего курса
  defp course_handler(course) do
    Enum.map(
      course,
      &%{
        short_name: &1.currency.short_name,
        value_for_sale: &1.value_for_sale,
        value_for_purchase: &1.value_for_purchase,
        best_sale: false,
        best_purchase: false
      }
    )
  end

  # Проверяет есть ли у филиала логотип, если нет заменяем на nil для отображения лого в виде цветной буквы
  defp ensure_default_logo(setting) do
    if setting.logo != "images/logo/default_logo.jpg",
      do: setting,
      else: Map.put(setting, :logo, nil)
  end

  # Проверяет находятся ли все валюты(usd, eur, rub) в дапазоне scrapped
  # Если нет, то в reduce НЕ добавляем такие обменные пункты
  def ensure_srapped_diapason(courses) do
    [usd, eur, rub] =
      ScrappedData.get_all()
      |> Enum.map(fn [_currency, buy, sale] ->
        {buy, ""} = buy |> Float.parse()
        {sale, ""} = sale |> Float.parse()
        [buy, sale]
      end)

    [usd_purchase, usd_sale] = usd
    [eur_purchase, eur_sale] = eur
    [rub_purchase, rub_sale] = rub

    courses
    |> Enum.reduce(
      [],
      fn map, acc ->
        usd = Enum.find(map.course, &(&1.short_name == "USD"))
        usd_range = if is_nil(usd), do: true, else: value_in_range?(usd.value_for_purchase, usd.value_for_sale, usd_purchase, usd_sale)

        eur = Enum.find(map.course, &(&1.short_name == "EUR"))
        eur_range = if is_nil(eur), do: true, else: value_in_range?(eur.value_for_purchase, eur.value_for_sale, eur_purchase, eur_sale)

        rub = Enum.find(map.course, &(&1.short_name == "RUB"))
        rub_range = if is_nil(rub), do: true, else: value_in_range?(rub.value_for_purchase, rub.value_for_sale, rub_purchase, rub_sale)

        is_range = usd_range && eur_range && rub_range |> IO.inspect(label: "kek")
        if is_range, do: acc ++ [map], else: acc
      end
    )
  end

  def value_in_range?("-", _purchase, _scrapped_purchase, _scrapped_sale), do: false
  def value_in_range?(_sale, "-", _scrapped_purchase, _scrapped_sale), do: false

  def value_in_range?(sale, purchase, scrapped_purchase, scrapped_sale) do
    {sale, ""} = sale |> Float.parse()
    {purchase, ""} = purchase |> Float.parse()

    if sale > scrapped_purchase and sale < scrapped_sale and
         purchase > scrapped_purchase and purchase < scrapped_sale do
      true
    else
      false
    end
  end
end
