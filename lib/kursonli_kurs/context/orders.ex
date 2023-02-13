defmodule KursonliKurs.Context.Orders do
  @moduledoc """
  Orders context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Order, Currency, Filial, Organization}
  alias KursonliKurs.Context.{Courses, Filials}

  require Logger

  @type order :: Order.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Order
    |> filter_by(opts)
    |> Courses.get_currency
    |> Filials.get_filail_name
    |> Repo.one()
  end

  def all(opts \\ []) do
    Order
    |> filter_by(opts)
    |> Courses.get_currency
    |> Filials.get_filail_name
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

  def count(opts \\ []) do
    Order
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  def order_list(type, city_id) do
    from(
      order in Order,
      where: order.type == ^type,
      join: filial in Filial,
      on: order.filial_id == filial.id and filial.city_id == ^city_id,
      join: org in Organization,
      on: filial.organization_id == org.id,
      join: c in Currency,
      on: order.currency_id == c.id,
      order_by: [desc: order.date],
      select: %{
        id: order.id,
        organization: org.name,
        filial_name: filial.name,
        type: order.type,
        filial: filial,
        filial_id: order.filial_id,
        fililal_address: filial.fililal_address,
        date: order.date,
        volume: order.volume,
        limit: order.limit,
        terms: order.terms,
        transfer: order.transfer,
        worker_id: order.worker_id,
        currency_short_name: c.short_name,
        worker_name: order.worker_name,
        worker_phone: order.worker_phone,
        course_sale: order.course
      }
    )
    |> Repo.all()
    |> PwHelper.Normalize.repo()
  end

  def order_one(id,city_id) do
    from(
      order in Order,
      where: order.id == ^id,
      join: filial in Filial,
      on: order.filial_id == filial.id and filial.city_id == ^city_id,
      join: org in Organization,
      on: filial.organization_id == org.id,
      join: c in Currency,
      on: order.currency_id == c.id,
      order_by: [desc: order.date],
      select: %{
        id: order.id,
        organization: org.name,
        filial_name: filial.name,
        type: order.type,
        filial: filial,
        filial_id: order.filial_id,
        fililal_address: filial.fililal_address,
        date: order.date,
        volume: order.volume,
        limit: order.limit,
        terms: order.terms,
        transfer: order.transfer,
        worker_id: order.worker_id,
        currency_short_name: c.short_name,
        worker_name: order.worker_name,
        worker_phone: order.worker_phone,
        course_sale: order.course
      }
    )
    |> Repo.one()
  end
end
