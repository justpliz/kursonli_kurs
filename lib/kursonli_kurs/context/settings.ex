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

  @doc """
  get setting info from filial_id.
  """
  def get_setting(query) do
  # TODO:
  # У меня есть запросы:
  # from(u in User, select: %{name: u.name}) |> Repo.One
  # from(u in User, select: %{last_name: u.last_name}) |> Repo.One
  # from(u in User, select: %{name: u.name, last_name: u.last_name}) |> Repo.One
  #
  # Я могу их как то оптимизировать? Например, я хочу передать, нужные мне поля в виде списка get_user([:name, :last_name]).
  # Как можно настроить селект, чтобы он брал то, что я отправляю в параметрах функции?
    s = from(s in Setting, select: s)
    from(query, preload: [setting: ^s])
  end
end
