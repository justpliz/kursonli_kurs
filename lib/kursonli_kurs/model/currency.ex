defmodule KursonliKurs.Model.Currency do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Course, Order}

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name short_name color)a
  @optional_fields ~w()a

  schema "currencies" do
    field :name, :string
    field :short_name, :string
    field :color, :string, default: "#ffffff"

    has_one :course, Course
    has_one :order, Order
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :short_name])
  end
end
