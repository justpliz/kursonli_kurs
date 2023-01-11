defmodule KursonliKurs.Context.Courses do
  @moduledoc """
  Courses context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Context.Currencies
  alias KursonliKurs.Model.{Currency, Course, Filial}

  require Logger

  @type course :: Course.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Course
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Course
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Course{}
    |> Course.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(course, params) :: {:ok, course} | {:error, Ecto.Changeset.t()}
  def update(course, params) do
    course
    |> Course.changeset(params)
    |> Repo.update()
  end

  def course_list_with_currencies() do
    from(
      course in Course,
      join: currency in Currency,
      on: course.currency_id == currency.id,
      select: %{
        id: course.id,
        value_for_sale: course.value_for_sale,
        value_for_purchase: course.value_for_purchase,
        currency_name: currency.name,
        currency_short_name: currency.short_name,
        currency_flag: currency.flag
      }
    )
    |> Repo.all
  end
end
