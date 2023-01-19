defmodule KursonliKurs.Context.Organizations do
  @moduledoc """
  Organizations context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Organization

  require Logger

  @type organization :: Organization.t()
  @type params :: Map.t()

  def get(opts \\ []) do
    Organization
    |> filter_by(opts)
    |> Repo.one()
  end

  def all(opts \\ []) do
    Organization
    |> filter_by(opts)
    |> Repo.all()
  end

  def create(params) do
    %Organization{}
    |> Organization.changeset(params)
    |> Repo.insert()
  end


  def delete(organization) do
    Repo.delete(organization)
  end

  @doc false
  @spec update(organization, params) :: {:ok, organization} | {:error, Ecto.Changeset.t()}
  def update(organization, params) do
    organization
    |> Organization.changeset(params)
    |> Repo.update()
  end
end
