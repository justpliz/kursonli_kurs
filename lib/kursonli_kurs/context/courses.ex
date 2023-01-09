defmodule KursonliKurs.Context.Courses do
  @moduledoc """
  Courses context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Course

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
end
