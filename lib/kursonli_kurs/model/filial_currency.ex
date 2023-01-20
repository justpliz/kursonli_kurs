defmodule KursonliKurs.Model.FilialCurrency do
  use Ecto.Schema

  import Ecto.Changeset

  # alias KursonliKurs.Model.{Filial, Currency}

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(filial_id curency_id)a
  @optional_fields ~w()a

  schema "filials_currencies" do
    field :filial_id, :string
    field :curency_id, :string

    timestamps()
  end

  @doc false
  def changeset(filial, attrs) do
    filial
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
