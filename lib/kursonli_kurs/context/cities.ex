defmodule KursonliKurs.Context.Cities do
  @moduledoc """
  City context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{City, Worker, Filial, Setting}
  alias KursonliKurs.Context.Cities

  require Logger

  @type city :: City.t()
  @type params :: Map.t()

  @doc false
  def get(opts \\ []) do
    City
    |> filter_by(opts)
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    City
    |> filter_by(opts)
    |> Repo.all()
  end

  @doc false
  def create(params) do
    %City{}
    |> City.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Удаление города по id. Если вызывается иключение возвращает :error.
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

  @doc false
  def count(opts \\ []) do
    City
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  @doc """
  get city info from city_id.
  """
  def get_city_name(query) do
    c = from(c in City, select: %{name: c.name})
    from(query, preload: [city: ^c])
  end

  @doc """
  Получение всех сотрудников города(сity_id).
  """
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
    |> Repo.all()
  end

  @doc """
  Получение информации о городе по filail_id
  """
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

  @doc """
  Количество активных филиалов города(city_id) у которых активна функция отображения.
  """
  def get_count_cities(city_id) do
    from(
      c in City,
      where: c.id == ^city_id,
      join: f in Filial,
      on: f.city_id == c.id and f.filial_active_status == :active,
      join: s in Setting,
      on: s.filial_id == f.id and s.visible_course_status == true
    )
    |> Repo.aggregate(:count)
  end
end
