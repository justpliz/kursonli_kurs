defmodule KursonliKurs.Context.Courses do
  @moduledoc """
  Courses context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.{Currency, Course}

  require Logger

  @type course :: Course.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Course
    |> filter_by(opts)
    |> get_currency
    |> Repo.one()
  end

  def all(opts \\ []) do
    Course
    |> filter_by(opts)
    |> get_currency
    |> Repo.all()
  end

  def create(params) do
    %Course{}
    |> Course.changeset(params)
    |> Repo.insert()
  end

  def delete(course) do
    Repo.delete(course)
  end

  @doc false
  @spec update(course, params) :: {:ok, course} | {:error, Ecto.Changeset.t()}
  def update(course, params) do
    course
    |> Course.changeset(params)
    |> Repo.update()
  end

  @doc """
  get currency info from course.currency_id
  f15a0dae-37bf-4bb0-9099-f67bc76d20de -> %{name: "Американский доллар", short_name: "USD"
  """
  def get_currency(query) do
    c = from(c in Currency, select: %{name: c.name, short_name: c.short_name})
    from(query, preload: [currency: ^c])
  end
end
