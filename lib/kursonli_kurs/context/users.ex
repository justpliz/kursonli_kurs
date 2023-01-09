defmodule KursonliKurs.Context.Users do
  @moduledoc """
  User context
  """
  use KursonliKurs.Context

  alias Hex.API.Key.Organization
  alias KursonliKurs.Model.User

  require Logger

  @type user :: User.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    User
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    User
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
     %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  @doc false
  @spec update(user, params) :: {:ok, user} | {:error, Ecto.Changeset.t()}
  def update(user, params) do
    user
    |> User.changeset(params)
    |> Repo.update()
  end
end
