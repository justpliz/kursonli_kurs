defmodule KursonliKurs.Context.Tariffs do
  @moduledoc """
  Tariff context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Tariff, Worker}

  require Logger

  @type tariff :: Tariff.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    WorkTariffer
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Tariff
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Tariff{}
    |> Tariff.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(tariff, params) :: {:ok, tariff} | {:error, Ecto.Changeset.t()}
  def update(tariff, params) do
    tariff
    |> Worker.changeset(params)
    |> Repo.update()
  end
end
