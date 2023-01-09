defmodule KursonliKurs.Context.Currencies do
  @moduledoc """
  Currency context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Currency

  require Logger

  @type currency :: Currency.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Currency
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Currency
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Currency{}
    |> Currency.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(currency, params) :: {:ok, currency} | {:error, Ecto.Changeset.t()}
  def update(currency, params) do
    currency
    |> Currency.changeset(params)
    |> Repo.update()
  end
end
