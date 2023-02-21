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

  def create_org_filial_worker(org_opts, filial_opts) do
    #TODO with -> transaction
    Repo.transaction(fn ->
      KursonliKurs.Context.Organizations.create(org_opts)
      KursonliKurs.Context.Filials.create(filial_opts)
    end)
  end

  # with {:ok, org} <- Organizations.create(org_opts),
  # filial_opts <- Map.put(filial_opts, :organization_id, org.id),
  # {:ok, filial} <-
  #   Filials.create_filial_worker_seting(
  #     filial_opts,
  #     worker_opts
  #   ),
  # params["currency"]
  # |> Enum.map(fn currency ->
  #   currency = String.to_integer(currency)

  #   Courses.create(%{
  #     date: Timex.now("Asia/Almaty"),
  #     currency_id: currency,
  #     filial_id: filial.id
  #   })

  #   FilialsCurrencies.create(%{currency_id: currency, filial_id: filial.id})
  # end) do
end
