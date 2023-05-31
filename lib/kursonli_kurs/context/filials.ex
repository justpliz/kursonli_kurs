defmodule KursonliKurs.Context.Filials do
  @moduledoc """
  Filials context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Context.{Currencies, Courses}

  alias KursonliKurs.Model.{
    Filial,
    City,
    Organization,
    Tariff,
    Setting,
    Worker
  }

  alias KursonliKurs.Context.{Filials, Workers, Settings, Cities}

  require Logger

  @type filial :: Filial.t()
  @type params :: Map.t()

  @doc false
  def get(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Cities.get_city_name()
    |> Repo.one()
  end

  @doc false
  def get_with_setting(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Cities.get_city_name()
    |> Settings.get_setting()
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Repo.all()
  end

  @doc false
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

  @doc false
  def count(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  @doc """
  get filial info from filial_id.
  """
  def get_filail_name(query) do
    f = from(f in Filial, select: %{name: f.name})
    from(query, preload: [filial: ^f])
  end

  @doc """
  Создание связки филиал-сотрудник-настройки.
  """
  def create_filial_worker_setting(filial_opts, worker_opts, setting_opts) do
    date = Timex.now("Asia/Almaty")
    {:ok, usd} = Currencies.do_get(short_name: "USD")
    {:ok, eur} = Currencies.do_get(short_name: "EUR")
    {:ok, rub} = Currencies.do_get(short_name: "RUB")

    with {:ok, filial} <- Filials.create(filial_opts),
         worker_opts <- Map.put(worker_opts, :filial_id, filial.id),
         {:ok, _worker} <- Workers.create(worker_opts),
         setting_opts <- Map.put(setting_opts, :filial_id, filial.id),
         {:ok, _setting} <- Settings.create(setting_opts),
         {:ok, _usd} <- Courses.create(%{date: date, currency_id: usd.id, filial_id: filial.id}),
         {:ok, _eur} <- Courses.create(%{date: date, currency_id: eur.id, filial_id: filial.id}),
         {:ok, _rub} <- Courses.create(%{date: date, currency_id: rub.id, filial_id: filial.id}) do
      {:ok, filial}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Получение информации о филиале, его настройках, организации, городе, тарифе.
  """
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
        link: setting.link,
        slug: setting.slug,
        url: setting.url,
        auto_update: setting.auto_update,
        shedule_period: setting.shedule_period,
        shedule_type: setting.shedule_type,
        email: worker.email
      }
    )
    |> Repo.all()
    |> Enum.map(&ensure_subdomen(&1))
    |> Enum.map(&ensure_auto_update(&1))
  end

  defp ensure_subdomen(filial) do
    subdomen =
      case filial.link do
        :slug -> filial.slug
        :url -> "filial_id"
        :filial_id -> "filial_id"
        _any -> "filial_id"
      end

    Map.put(filial, :subdomen, subdomen)
  end

  defp ensure_auto_update(filial) do
    # TODO Пересмотреть возможность перенсти функционал в схему.
    hum_shedule_type =
      case filial.shedule_type do
        :full -> "круглосточно"
        :nine_twenty -> "с 09:00 до 20:00"
        :nine_twenty_two -> "с 09:00 до 22:00"
        _any -> "Неизвестно"
      end

    hum_auto_update = if filial.auto_update, do: "Да, #{hum_shedule_type}", else: "Нет"
    Map.put(filial, :hum_auto_update, hum_auto_update)
  end
end
