defmodule KursonliKurs.Context.Notifications do
  @moduledoc """
  Notification context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Notification
  alias KursonliKurs.Context.Notifications

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

  def check_remaining_days(paid_up_to) do
    diff_days = Timex.diff(paid_up_to, Timex.today(), :day)
    {:ok, expiration} = Notifications.do_get(name: "expiration")

    new_title =
      if diff_days >= 0 and diff_days <= 7 do
        String.replace(expiration.title, "#", "#{diff_days}")
      end

    Map.put(expiration, :title, new_title)
  end
end
