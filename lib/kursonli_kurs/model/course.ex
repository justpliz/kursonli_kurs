defmodule KursonliKurs.Model.Course do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(first_name last_name password phone filial_id)a
  @optional_fields ~w()a

  schema "courses" do
    field :value_for_sale, :string
    field :value_for_purchase, :string

    # belongs_to :filial, Filial, type: :binary_id
    # TODO ref currencies

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
