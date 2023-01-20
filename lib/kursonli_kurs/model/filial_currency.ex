defmodule KursonliKurs.Model.FilialCurrency do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Filial}

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(filial_id currency_id)a
  @optional_fields ~w()a

  schema "filials_currencies" do
    field :currency_id, :integer

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(filial, attrs) do
    filial
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
