defmodule KursonliKurs.Context.Organizations do
  @moduledoc """
  Organizations context
  """
  use KursonliKurs.Context

  alias KursonliKurs.Model.Organization

  alias KursonliKurs.Context.{Organizations, Filials}

  require Logger

  @type organization :: Organization.t()
  @type params :: Map.t()

  @doc false
  def get(opts \\ []) do
    Organization
    |> filter_by(opts)
    |> Repo.one()
  end

  @doc false
  def all(opts \\ []) do
    Organization
    |> filter_by(opts)
    |> Repo.all()
  end

  @doc false
  def create(params) do
    %Organization{}
    |> Organization.changeset(params)
    |> Repo.insert()
  end

  @doc false
  def delete(organization) do
    Repo.delete(organization)
  end

  @doc false
  def count(opts \\ []) do
    Organization
    |> filter_by(opts)
    |> Repo.aggregate(:count)
  end

  @doc false
  @spec update(organization, params) :: {:ok, organization} | {:error, Ecto.Changeset.t()}
  def update(organization, params) do
    organization
    |> Organization.changeset(params)
    |> Repo.update()
  end

  def create_org_filial_worker_setting(org_opts, filial_opts, worker_opts, setting_opts) do
    KursonliKurs.Repo.transaction(fn ->
      {:ok, org} = Organizations.create(org_opts)
      filial_opts = Map.put(filial_opts, :organization_id, org.id)

      {:ok, _filial} =
        Filials.create_filial_worker_setting(filial_opts, worker_opts, setting_opts)

      {:ok, org}
    end)
  end
end
