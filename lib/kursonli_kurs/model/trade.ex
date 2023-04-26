defmodule KursonliKurs.Model.Trade do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Worker, Order}

  @type t :: %__MODULE__{}
  # @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(volume status worker_id order_id)a
  @optional_fields ~w(item_order terms)a

  schema "trades" do
    field :terms, :string, default: ""
    field :volume, :string
    field :status, OrderStatus, default: "active"
    field :item_order, :map
    belongs_to :order, Order, type: :binary_id
    belongs_to :worker, Worker, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(worker, attrs) do
    worker
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
