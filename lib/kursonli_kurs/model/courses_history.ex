defmodule KursonliKurs.Model.CoursesHistory do
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(date value_for_sale value_for_purchase currency)a
  @optional_fields ~w()a

  schema "courses_histories" do
    field :date, :naive_datetime
    field :value_for_sale, :string
    field :value_for_purchase, :string
    field :currency, :string

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :short_name])
  end
end
