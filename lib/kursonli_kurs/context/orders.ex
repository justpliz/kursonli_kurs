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

  def order_list() do
    from(
      order in Order,
      join: course in Course,
      on: order.course_id == course.id,
      join: currency in Currency,
      on: course.currency_id == currency.id,
      join: filial in Filial,
      on: order.filial_id == filial.id,
      join: org in Organization,
      on: filial.organization_id == org.id,
      select: %{
        id: order.id,
        organization: org.name,
        date: order.date,
        course_sale: course.value_for_sale,
        course_purchase: course.value_for_purchase,
        currency_short_name: currency.short_name,
        volume: order.volume,
        terms: order.terms,
        transfer: order.transfer
      }
    )
    |> Repo.all
  end
end
