defmodule KursonliKurs.Model.Setting do
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(address coordinates photo logo description filial_id)a
  @optional_fields ~w(tags schedule phones license qualities colors email subdomen)a

  schema "settings" do
    field :tags, {:array, :string}
    field :coordinates, {:array, :string}
    field :address, :string
    field :logo, :string, default: "default_logo.jpg"
    field :photo, :string, default: "default_photo.jpg"
    field :license, :string
    field :email, :string
    field :subdomen, :string
    field :description, :string, default: "Описание будет позже"
    field :schedule, :map
    field :phones, :map
    field :qualities, :map
    field :colors, :map

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
