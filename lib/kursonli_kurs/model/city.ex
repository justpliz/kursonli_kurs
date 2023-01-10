defmodule KursonliKurs.Model.City do
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.{Filial}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name short_name)a
  @optional_fields ~w(index)a

  schema "cities" do
    field :name, :string
    field :short_name, :string
    field :index, :string

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :short_name])
  end
end
