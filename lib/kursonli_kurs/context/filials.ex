defmodule KursonliKurs.Context.Filials do
  @moduledoc """
  Filials context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Filial
  alias KursonliKurs.Context.{Filials, Workers, Settings}

  require Logger

  @type filial :: Filial.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Filial
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Filial{}
    |> Filial.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(filial, params) :: {:ok, filial} | {:error, Ecto.Changeset.t()}
  def update(filial, params) do
    filial
    |> Filial.changeset(params)
    |> Repo.update()
  end

  def create_filial_worker_seting(filial_opts, worker_opts, address \\ "") do
    with {:ok, filial} <- Filials.create(filial_opts),
         worker_opts <- Map.put(worker_opts, :filial_id, filial.id),
         {:ok, _worker} <- Workers.create(worker_opts),
         {:ok, _setting} <- Settings.create(%{filial_id: filial.id, address: address, coordinates: ["0","0"]}) do
      {:ok, filial}
    end
  end

  def filial_list() do
    from(
      filial in Filial,
      select: %{
        id: filial.id,
        filial_name: filial.name,
      }
    )
    |> Repo.all()
  end
end
