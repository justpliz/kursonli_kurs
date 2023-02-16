defmodule KursonliKurs.Model.Tariff do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name price description is_active)a
  @optional_fields ~w()a

  schema "tariffs" do
    field :name, :string
    field :price, :string
    field :description, :string
    field :is_active, :boolean, default: false

    has_one :filial, Filial
  end

  @doc false
  def changeset(tariff, attrs) do
    tariff
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name])
  end
end
