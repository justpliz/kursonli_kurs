defmodule KursonliKurs.Model.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Order

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(login password)a
  @optional_fields ~w(email phone)a

  schema "users" do
    field :login, :string
    field :email, :string
    field :phone, :string
    field :password, :string

    belongs_to :order, Order, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:login, :email, :phone])
  end
end
