defmodule KursonliKurs.Context.Orders do
  @moduledoc """
  Orders context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Order

  require Logger

  @type order :: Order.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Order
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Order
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Order{}
    |> Order.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(order, params) :: {:ok, order} | {:error, Ecto.Changeset.t()}
  def update(order, params) do
    order
    |> Order.changeset(params)
    |> Repo.update()
  end
end
