defmodule KursonliKurs.Model.Tariff do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name description)a
  @optional_fields ~w()a

  schema "tariffs" do
    field :name, :string
    field :description, :string

    has_one :filial, Filial
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name])
  end
end
