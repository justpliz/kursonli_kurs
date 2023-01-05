defmodule KursonliKurs.ContextFilters do
  @moduledoc """
  Ecto Query filters
  """
  import Ecto.Query

  # Quick search

  def filter_next({:query, {nil, _}}, query), do: query

  def filter_next({:query, {q, f}}, query) do
    q = "%#{q}%"
    where(query, [qq], ilike(field(qq, ^f), ^q))
  end

  def filter_next({:query, nil}, query), do: query
  def filter_next({:query, ""}, query), do: query

  def filter_next({:query, q}, query) do
    q = "%#{q}%"
    where(query, [a], ilike(a.title, ^q))
  end

  # Pagination
  def filter_next({:limit, limit}, query) do
    limit(query, ^limit)
  end

  def filter_next({:offset, offset}, query) do
    offset(query, ^offset)
  end

  # Ordering
  def filter_next({:order, opts}, query) do
    Enum.reduce(opts, query, &order_next/2)
  end

  # Dynamic conditions
  def filter_next({:conditions, conditions}, query), do: where(query, ^conditions)
  def filter_next({_field, {:conditions, conditions}}, query), do: where(query, ^conditions)

  # Abstract
  def filter_next({field, :is_nil}, query) do
    where(query, [a], is_nil(field(a, ^field)))
  end

  def filter_next({field, :not_nil}, query) do
    where(query, [a], not is_nil(field(a, ^field)))
  end

  def filter_next({field, {:gte, value}}, query) do
    where(query, [a], field(a, ^field) >= ^value)
  end

  def filter_next({field, {:lte, value}}, query) do
    where(query, [a], field(a, ^field) <= ^value)
  end

  def filter_next({field, {:in, values}}, query) do
    where(query, [a], field(a, ^field) in ^values)
  end

  def filter_next({field, {:not_in, values}}, query) do
    where(query, [a], field(a, ^field) not in ^values)
  end

  def filter_next({field, {:neq, value}}, query) do
    where(query, [a], field(a, ^field) != ^value)
  end

  def filter_next({field, :in_past}, query) do
    now = Timex.now()
    where(query, [a], field(a, ^field) < ^now)
  end

  def filter_next({field, :in_future}, query) do
    now = Timex.now()
    where(query, [a], field(a, ^field) > ^now)
  end

  def filter_next({field, {:older_than, datetime}}, query) do
    where(query, [a], field(a, ^field) > ^datetime)
  end

  def filter_next({_field, nil}, query), do: query

  def filter_next({field, value}, query) do
    where(query, [a], field(a, ^field) == ^value)
  end

  def order_next({:asc, field}, query) do
    order_by(query, [r], asc: field(r, ^field))
  end

  def order_next({:desc, field}, query) do
    order_by(query, [r], desc: field(r, ^field))
  end
end
