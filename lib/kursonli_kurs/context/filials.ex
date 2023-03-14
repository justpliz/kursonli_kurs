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
        setting: &1.setting,
        course: course_handler(&1.filial.course),
        filial_id: &1.filial.id,
        filial_address: &1.filial.filial_address,
        filial_name: &1.filial.name,
        date: hd(&1.filial.course).date,
        date_h: GeneralHelper.date_to_string_time_h(hd(&1.filial.course).date),
        date_m: GeneralHelper.date_to_string_time_m(hd(&1.filial.course).date),
        date_s: GeneralHelper.date_to_string_time_s(hd(&1.filial.course).date),
        humanizated_date: GeneralHelper.humanizated_date(hd(&1.filial.course).date),
        first_letter: &1.filial.name |> String.trim() |> String.first |> String.upcase()
      }
    )
    |> Enum.sort_by(&(&1.date), :desc)
  end

  defp course_handler(course) do
    Enum.map(
      course,
      &%{
        short_name: &1.currency.short_name,
        value_for_sale: &1.value_for_sale,
        value_for_purchase: &1.value_for_purchase
      }
    )
  end
end
