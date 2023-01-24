defmodule KursonliKurs.Context.Orders do
  @moduledoc """
  Orders context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Order, Course, Currency, Filial, Organization}

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

  def delete(order) do
    Repo.delete(order)
  end

  def order_list(type \\ :sale) do
    from(
      order in Order,
      where: order.type == ^type,
      join: filial in Filial,
      on: order.filial_id == filial.id,
      join: org in Organization,
      on: filial.organization_id == org.id,
      join: c in Currency,
      on: order.currency_id == c.id,
      select: %{
        id: order.id,
        organization: org.name,
        filial_name: filial.name,
        filial: filial,
        filial_id: order.filial_id,
        date: order.date,
        volume: order.volume,
        terms: order.terms,
        transfer: order.transfer,
        currency_short_name: c.short_name,
        course_sale: order.course
      }
    )
    |> Repo.all()
    |> PwHelper.Normalize.repo()
  end
end
