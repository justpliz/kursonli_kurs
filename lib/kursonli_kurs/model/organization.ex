defmodule KursonliKurs.Model.Organization do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Worker, Admin}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name iin admin_id)a
  @optional_fields ~w()a

  schema "organizations" do
    field :name, :string
    field :iin, :string

    belongs_to :admin, Admin, type: :binary_id

    has_one :filial, Filial

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :iin])
  end
end
