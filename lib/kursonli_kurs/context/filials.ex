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
  get filial info from filial_id
  """
  def get_filail_name(query) do
    f = from(f in Filial, select: %{name: f.name})
    from(query, preload: [filial: ^f])
  end

  @doc """
  Создание связки филиал-сотрудник-настройки
  """
  def create_filial_worker_setting(filial_opts, worker_opts, slug) do
    with {:ok, filial} <- Filials.create(filial_opts),
         worker_opts <- Map.put(worker_opts, :filial_id, filial.id),
         {:ok, _worker} <- Workers.create(worker_opts),
         {:ok, _setting} <- Settings.create(%{filial_id: filial.id, slug: slug}) do
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
        slug: setting.slug,
        email: worker.email
      }
    )
    |> Repo.all()
  end

  @doc """
  Получение списка курсов филиала по filial_id
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
            slug: s.slug,
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
    # |> ensure_srapped_diapason
    |> Enum.sort_by(& &1.date, {:desc, NaiveDateTime})
  end

  defp course_handler(course) do
    Enum.map(
      course,
      &%{
        short_name: &1.currency.short_name,
        sale: &1.sale,
        buy: &1.buy,
        best_sale: false,
        best_buy: false
      }
    )
  end

  defp ensure_default_logo(setting) do
    if setting.logo != "images/logo/default_logo.jpg",
      do: setting,
      else: Map.put(setting, :logo, nil)
  end

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
        usd_range = if is_nil(usd), do: true, else: value_in_range?(usd.buy, usd.sale, usd_buy, usd_sale)

        eur = Enum.find(map.course, &(&1.short_name == "EUR"))
        eur_range = if is_nil(eur), do: true, else: value_in_range?(eur.buy, eur.sale, eur_buy, eur_sale)

        rub = Enum.find(map.course, &(&1.short_name == "RUB"))
        rub_range = if is_nil(rub), do: true, else: value_in_range?(rub.buy, rub.sale, rub_buy, rub_sale)

        is_range = usd_range && eur_range && rub_range |> IO.inspect(label: "kek")
        if is_range, do: acc ++ [map], else: acc
      end
    )
  end

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
end
