defmodule KursonliKurs.Context.Trades do
  @moduledoc """
  Trade context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Trade, Order}

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

  def update(trade, params) do
    trade
    |> Trade.changeset(params)
    |> Repo.update()
  end

  def get_by_id_worker(worker_id) do
    from(
      trade in Trade,
      where: trade.worker_id == ^worker_id,
      join: order in Order,
      on: trade.order_id == order.id
    )
    |> Repo.all()
    |> PwHelper.Normalize.repo()
  end
end
