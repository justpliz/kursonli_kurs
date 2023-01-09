defmodule KursonliKurs.Context.Admins do
  @moduledoc """
  Admin context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Admin
  import KursonliKursWeb.GeneralHelper, only: [hash_str: 1]

  require Logger

  @type admin :: Admin.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Admin
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Admin
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    params = %{login: params.login, password: hash_str(params.password)}

    %Admin{}
    |> Admin.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(admin, params) :: {:ok, admin} | {:error, Ecto.Changeset.t()}
  def update(admin, params) do
    admin
    |> Admin.changeset(params)
    |> Repo.update()
  end
end
