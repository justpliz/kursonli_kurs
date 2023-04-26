defmodule KursonliKurs.Model.Worker do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Order, Trade}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(email password filial_id)a
  @optional_fields ~w(name)a

  schema "workers" do
    field :password, :string
    field :email, :string
    field :name, :string

    has_one :order, Order
    has_one :trade, Trade

    belongs_to :filial, Filial, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(worker, attrs) do
    worker
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:email])
  end
end
