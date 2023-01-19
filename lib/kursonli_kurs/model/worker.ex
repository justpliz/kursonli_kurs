defmodule KursonliKurs.Model.Worker do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Order}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(email password phone filial_id)a
  @optional_fields ~w()a

  schema "workers" do
    field :password, :string
    field :phone, :string
    field :email, :string

    has_one :filial, Filial
    has_one :order, Order

    timestamps()
  end

  @doc false
  def changeset(worker, attrs) do
    worker
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:email, :phone])
  end
end
