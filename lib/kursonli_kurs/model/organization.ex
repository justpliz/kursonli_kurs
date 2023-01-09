defmodule KursonliKurs.Model.Organization do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Worker, Admin, Order}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name iin admin_id)a
  @optional_fields ~w(photo)a

  schema "organizations" do
    field :name, :string
    field :iin, :string
    field :photo, :string, default: "default_photo.jpg"

    belongs_to :admin, Admin, type: :binary_id
    belongs_to :order, Order, type: :binary_id

    has_one :filial, Filial
    has_one :worker, Worker

    # TODO ref order, tariff

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :iin])
  end
end
