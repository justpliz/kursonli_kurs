defmodule KursonliKurs.Model.Order do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Worker, Course}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(date volume type transfer status number filial_id worker_id course_id)a
  @optional_fields ~w(terms limit)a

  schema "orders" do
    field :date, :naive_datetime
    field :volume, :string
    field :terms, :string
    field :limit, :string
    field :number, :string

    field :type, OrderType, default: "purchase"
    field :transfer, OrderTransfer, default: "red"
    field :status, OrderStatus, default: "active"

    belongs_to :filial, Filial, type: :binary_id
    belongs_to :worker, Worker, type: :binary_id
    belongs_to :course, Course, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> foreign_key_constraint(:worker_id)
    # |> foreign_key_constraint(:orders_filial_id_fkey)
    |> validate_required(@required_fields)
  end
end
