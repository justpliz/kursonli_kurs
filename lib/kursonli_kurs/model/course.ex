defmodule KursonliKurs.Model.Course do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Currency, Filial}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}
  # Определение составного уникального ключа на полях `currency_id` и `filial_id`
  @unique_constraint {:index_currency_filial, [:currency_id, :filial_id], name: :index_currency_filial, unique: true}


  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(currency_id filial_id date buy sale)a
  @optional_fields ~w()a

  schema "courses" do
    field :buy, :string, default: "-"
    field :sale, :string, default: "-"
    field :date, :naive_datetime

    belongs_to :currency, Currency
    belongs_to :filial, Filial, type: :binary_id

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:currency_id, :filial_id], message: "already exists")
  end
end
