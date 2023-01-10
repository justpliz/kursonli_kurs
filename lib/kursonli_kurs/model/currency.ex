defmodule KursonliKurs.Model.Currency do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Order

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name short_name)a
  @optional_fields ~w(flag)a

  schema "currencies" do
    field :name, :string
    field :short_name, :string
    field :flag, :string

    belongs_to :order, Order, type: :binary_id
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :short_name])
  end
end
