defmodule KursonliKurs.Model.Course do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Currency, Filial}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(currency_id filial_id date value_for_sale value_for_purchase)a
  @optional_fields ~w()a

  schema "courses" do
    field :value_for_sale, :string, default: "-"
    field :value_for_purchase, :string, default: "-"
    field :date, :naive_datetime

    belongs_to :currency, Currency
    belongs_to :filial, Filial, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
