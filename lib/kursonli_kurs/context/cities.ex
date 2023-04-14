defmodule KursonliKurs.Context.Cities do
  @moduledoc """
  City context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{City, Worker, Filial}
  alias KursonliKurs.Context.Cities

  require Logger

  @type city :: City.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    City
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    City
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %City{}
    |> City.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Удаление города по id. Если вызывается иключение возвращает :error
  """
  def delete(city_id) do
    city = Cities.get(id: city_id)
    try do
      Repo.delete(city)
    rescue
      _ -> {:error, city}
    end
  end

  @doc false
  @spec update(city, params) :: {:ok, city} | {:error, Ecto.Changeset.t()}
  def update(city, params) do
    city
    |> City.changeset(params)
    |> Repo.update()
  end

  def count(opts \\ []) do
    City
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  @doc """
  get city info from city_id
  """
  def get_city_name(query) do
    c = from(c in City, select: %{name: c.name})
    from(query, preload: [city: ^c])
  end

  def get_all_users_by_city(city_id) do
    from(
      f in Filial,
      where: f.city_id == ^city_id,
      join: w in Worker,
      on: w.filial_id == f.id,
      select: %{
        worker_id: w.id,
        worker_name: w.name,
        filial_name: f.name
      }
    )
    |> Repo.all
  end
end
