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

  @doc false
  def get(opts \\ []) do
    Notification
    |> filter_by(opts)
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    Notification
    |> filter_by(opts)
    |> Repo.all()
  end

  @doc false
  def create(params) do
    %Notification{}
    |> Notification.changeset(params)
    |> Repo.insert()
  end

  @doc false
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

  @doc """
  Возвращает объявление об скором окончании тарифа
  если осталось менее 7 дней, в противном случае nil.
  """
  def check_remaining_days(paid_up_to) do
    diff_days = Timex.diff(paid_up_to, Timex.today(), :day)
    {:ok, expiration} = Notifications.do_get(name: "expiration")

      if diff_days >= 0 and diff_days <= 7 do
        new_title = String.replace(expiration.title, "#", "#{diff_days}")
        Map.put(expiration, :title, new_title)
      else
        nil
      end
  end
end
