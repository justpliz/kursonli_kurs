defmodule KursonliKurs.Context.Settings do
  @moduledoc """
  Setting context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Setting
  alias KursonliKurs.Context.Settings

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

  def get_image_path(nil, type, filial_id) do
    {:ok, setting} = Settings.do_get(filial_id: filial_id)

    case type do
      :logo -> setting.logo
      :photo -> setting.photo
    end
  end

  def get_image_path(upload, type, _filial_id) do
    new_path =
      case type do
        :logo -> Path.expand("priv/static/images/logo/#{upload.filename}")
        :photo -> Path.expand("priv/static/images/photo/#{upload.filename}")
      end

    File.cp(upload.path, new_path)

    case type do
      :logo -> "images/logo/#{upload.filename}"
      :photo -> "images/photo/#{upload.filename}"
    end
  end
end
