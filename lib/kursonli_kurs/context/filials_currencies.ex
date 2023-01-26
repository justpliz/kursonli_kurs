defmodule KursonliKurs.Context.FilialsCurrencies do
  @moduledoc """
  Filials context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.FilialCurrency

  require Logger

  @type filial_currency :: Filial.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    FilialCurrency
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    FilialCurrency
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %FilialCurrency{}
    |> FilialCurrency.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(filial_currency, params) :: {:ok, filial_currency} | {:error, Ecto.Changeset.t()}
  def update(filial_currency, params) do
    filial_currency
    |> FilialCurrency.changeset(params)
    |> Repo.update()
  end

  def count(opts \\ []) do
    FilialCurrency
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end
end
