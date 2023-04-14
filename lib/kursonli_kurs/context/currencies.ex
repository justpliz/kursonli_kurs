defmodule KursonliKurs.Context.Currencies do
  @moduledoc """
  Currency context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Currency, FilialCurrency}
  alias KursonliKurs.Context.Currencies

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

  @doc """
  Удаление валюты по id. Если вызывается иключение возвращает :error
  """
  def delete(currency_id) do
    currency = Currencies.get(id: currency_id)
    try do
      Repo.delete(currency)
    rescue
      _ -> {:error, currency}
    end
  end

  @spec update(currency, params) :: {:ok, currency} | {:error, Ecto.Changeset.t()}
  def update(currency, params) do
    currency
    |> Currency.changeset(params)
    |> Repo.update()
  end

  def get_not_mine_crrencies(filial_id) do
    from(
      c in Currency,
      join: fc in FilialCurrency,
      on: fc.filial_id == ^filial_id and c.id not in [fc.currency_id],
      select: c
    )
    |> Repo.all
  end
end
