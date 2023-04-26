defmodule KursonliKurs.Model.Admin do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Organization

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(login password)a
  @optional_fields ~w()a

  schema "admins" do
    field :login, :string
    field :password, :string

    has_one :organization, Organization
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:login)
  end
end
