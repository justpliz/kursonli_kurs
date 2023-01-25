defmodule KursonliKurs.Model.Setting do
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(address coordinates filial_id)a
  @optional_fields ~w(tags description photo schedule phones qualities)a

  schema "settings" do
    field :tags, {:array, :string}
    field :address, :string
    field :photo, :string, default: "default_photo.jpg"
    field :description, :string
    field :coordinates, {:array, :string}
    field :schedule, :map
    field :phones, :string
    field :qualities, :map

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
