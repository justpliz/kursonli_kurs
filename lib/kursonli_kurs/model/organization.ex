defmodule KursonliKurs.Model.Organization do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Worker, Admin}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name password admin_id)a
  @optional_fields ~w(photo)a

  schema "organizations" do
    field :name, :string
    field :password, :string
    field :photo, :string, default: "default_photo.jpg"

    belongs_to :admin, Admin, type: :binary_id

    has_one :filial, Filial
    has_one :worker, Worker

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
