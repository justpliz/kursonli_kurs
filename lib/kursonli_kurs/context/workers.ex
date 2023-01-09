defmodule KursonliKurs.Context.Workers do
  @moduledoc """
  Workers context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Worker

  require Logger

  @type worker :: Worker.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Worker
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Worker
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Worker{}
    |> Worker.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(worker, params) :: {:ok, worker} | {:error, Ecto.Changeset.t()}
  def update(worker, params) do
    worker
    |> Worker.changeset(params)
    |> Repo.update()
  end
end
