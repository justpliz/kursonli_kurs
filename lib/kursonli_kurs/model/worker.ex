defmodule KursonliKurs.Model.Worker do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Organization, Order}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(first_name last_name email password phone)a
  @optional_fields ~w()a

  schema "workers" do
    field :first_name, :string
    field :last_name, :string
    field :password, :string
    field :phone, :string
    field :email, :string

    belongs_to :organization, Organization, type: :binary_id
    belongs_to :order, Order, type: :binary_id

    # TODO ref order

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
