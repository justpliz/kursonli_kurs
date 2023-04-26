defmodule KursonliKurs.Model.City do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name eng_name)a
  @optional_fields ~w()a

  schema "cities" do
    field :name, :string
    field :eng_name, :string

    has_one :filial, Filial
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name])
  end
end
