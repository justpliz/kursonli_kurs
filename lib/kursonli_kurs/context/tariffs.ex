defmodule KursonliKurs.Context.Tariffs do
  @moduledoc """
  Tariff context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Tariff
  alias KursonliKurs.Context.Tariffs

  require Logger

  @type tariff :: Tariff.t()
  @type params :: Map.t()

  @doc false
  def get(opts \\ []) do
    Tariff
    |> filter_by(opts)
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    Tariff
    |> filter_by(opts)
    |> Repo.all()
  end

  @doc false
  def create(params) do
    %Tariff{}
    |> Tariff.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Удаление тарифа по id. Если вызывается иключение возвращает :error.
  """
  def delete(tariff_id) do
    tariff = Tariffs.get(id: tariff_id)
    try do
      Repo.delete(tariff)
    rescue
      _ -> {:error, tariff}
    end
  end

  @doc false
  @spec update(tariff, params) :: {:ok, tariff} | {:error, Ecto.Changeset.t()}
  def update(tariff, params) do
    tariff
    |> Tariff.changeset(params)
    |> Repo.update()
  end
end
