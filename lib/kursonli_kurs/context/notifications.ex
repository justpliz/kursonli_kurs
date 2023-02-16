defmodule KursonliKurs.Context.Notifications do
  @moduledoc """
  Notification context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Notification

  require Logger

  @type notification :: Notification.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Notification
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Notification
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Notification{}
    |> Notification.changeset(params)
    |> Repo.insert()
  end

  def delete(city) do
    Repo.delete(city)
  end

  @doc false
  @spec update(notification, params) :: {:ok, notification} | {:error, Ecto.Changeset.t()}
  def update(notification, params) do
    notification
    |> Notification.changeset(params)
    |> Repo.update()
  end
end
