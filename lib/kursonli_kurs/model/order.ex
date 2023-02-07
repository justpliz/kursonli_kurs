defmodule KursonliKurs.Model.Order do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial, Worker, Trade}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(course date volume type transfer number filial_id worker_id currency_id)a
  @optional_fields ~w(terms limit worker_name worker_phone)a

  schema "orders" do
    field :date, :naive_datetime
    field :volume, :string
    field :terms, :string
    field :limit, :string
    field :number, :string
    field :course, :string
    field :worker_name, :string
    field :worker_phone, :string
    field :type, OrderType, default: "purchase"
    field :transfer, OrderTransfer, default: "red"

    field :currency_id, :id

    belongs_to :filial, Filial, type: :binary_id
    belongs_to :worker, Worker, type: :binary_id

    has_one :trade, Trade

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
