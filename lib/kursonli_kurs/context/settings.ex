defmodule KursonliKurs.Context.Settings do
  @moduledoc """
  Setting context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Setting

  require Logger

  @type setting :: Setting.t()
  @type params :: Map.t()

  @doc false
  def get(opts \\ []) do
    Setting
    |> filter_by(opts)
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    Setting
    |> filter_by(opts)
    |> Repo.all()
  end

  @doc false
  def create(params) do
    %Setting{}
    |> Setting.changeset(params)
    |> Repo.insert()
  end

  @doc false
  def delete(city) do
    Repo.delete(city)
  end

  @doc false
  @spec update(setting, params) :: {:ok, setting} | {:error, Ecto.Changeset.t()}
  def update(setting, params) do
    setting
    |> Setting.changeset(params)
    |> Repo.update()
  end
end
