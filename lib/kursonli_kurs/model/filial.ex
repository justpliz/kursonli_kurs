defmodule KursonliKurs.Model.Filial do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Organization, Order, City}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name address city_id organization_id)a
  @optional_fields ~w(tags)a

  schema "filials" do
    field :name, :string
    field :address, :string
    field :tags, {:array, :string}

    belongs_to :organization, Organization, type: :binary_id
    belongs_to :city, City, type: :binary_id

    belongs_to :order, Order, type: :binary_id
    # TODO order assoc

    timestamps()
  end

  @doc false
  def changeset(filial, attrs) do
    filial
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
