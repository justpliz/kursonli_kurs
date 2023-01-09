defmodule KursonliKurs.Context.Cities do
  @moduledoc """
  City context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.City

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

  @doc false
  @spec update(city, params) :: {:ok, city} | {:error, Ecto.Changeset.t()}
  def update(city, params) do
    city
    |> City.changeset(params)
    |> Repo.update()
  end

end
