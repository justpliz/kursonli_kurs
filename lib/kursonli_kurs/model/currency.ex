defmodule KursonliKurs.Model.Currency do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Course, Filial, FilialCurrency}

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name short_name color)a
  @optional_fields ~w()a

  schema "currencies" do
    field :name, :string
    field :short_name, :string
    field :color, :string, default: "#ffffff"

    # Many-to-Many
    many_to_many :filials, Filial, join_through: "filials_currencies"
    has_one :filials_currencies, FilialCurrency

    has_one :course, Course
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :short_name])
  end
end
