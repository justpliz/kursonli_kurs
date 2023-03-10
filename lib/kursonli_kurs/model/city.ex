defmodule KursonliKurs.Model.City do
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name)a
  @optional_fields ~w(short_name eng_name index)a

  schema "cities" do
    field :name, :string
    field :short_name, :string
    field :eng_name, :string
    field :index, :string

    has_one :filial, Filial
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :short_name])
  end
end
