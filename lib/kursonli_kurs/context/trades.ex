defmodule KursonliKurs.Context.Trades do
  @moduledoc """
  Trade context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Trade

  require Logger

  @type trade :: Trade.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Trade
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Trade
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Trade{}
    |> Trade.changeset(params)
    |> Repo.insert()
  end

  def delete(trade) do
    Repo.delete(trade)
  end

  @doc false
  @spec update(trade, params) :: {:ok, trade} | {:error, Ecto.Changeset.t()}
  def update(trade, params) do
    trade
    |> Trade.changeset(params)
    |> Repo.update()
  end

end
