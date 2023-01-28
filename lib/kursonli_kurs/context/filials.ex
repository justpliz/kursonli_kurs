defmodule KursonliKurs.Context.Filials do
  @moduledoc """
  Filials context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Filial, City, Organization, Tariff, FilialCurrency, Currency, Course}
  alias KursonliKurs.Context.{Filials, Workers, Settings}

  require Logger

  @type filial :: Filial.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Filial
    |> filter_by(opts)
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

  def create_filial_worker_seting(filial_opts, worker_opts, address \\ "") do
    with {:ok, filial} <- Filials.create(filial_opts),
         worker_opts <- Map.put(worker_opts, :filial_id, filial.id),
         {:ok, _worker} <- Workers.create(worker_opts),
         {:ok, _setting} <-
           Settings.create(%{filial_id: filial.id, address: address, coordinates: ["0", "0"]}) do
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
      left_join: tariff in Tariff,
      on: filial.tariff_id == tariff.id,
      select: %{
        id: filial.id,
        filial_name: filial.name,
        org_name: org.name,
        payment_status: filial.payment_status,
        tariff_name: tariff.name,
        tariff_price: tariff.price,
        city_name: city.name
      }
    )
    |> Repo.all()
  end

  def get_courses_list(filial_id) do
    from(
      filial in Filial,
      where: filial.id == ^filial_id,
      join: fc in FilialCurrency,
      on: fc.filial_id == filial.id,
      join: c in Currency,
      on: c.id == fc.currency_id,
      join: course in Course,
      on: course.currency_id == c.id,
      select: %{
        course_id: course.id,
        currency_name: c.name,
        currency_short_name: c.short_name,
        value_for_sale: course.value_for_sale,
        value_for_purchase: course.value_for_purchase,
        updated_at: course.updated_at
      }
    )
    |> Repo.all()
  end
end
