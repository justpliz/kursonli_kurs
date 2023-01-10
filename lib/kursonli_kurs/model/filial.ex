defmodule KursonliKurs.Model.Filial do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{City, Organization, Tariff, Order, Course}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name address city_id organization_id)a
  @optional_fields ~w(tags)a

  schema "filials" do
    field :name, :string
    field :tags, {:array, :string}
    field :address, :string
    field :photo, :string, default: "default_photo.jpg"
    field :description, :string
    field :paid_up_to, :naive_datetime

    field :payment_status, PaymentStatus, default: "not_paid"

    belongs_to :city, City, type: :binary_id
    belongs_to :organization, Organization, type: :binary_id
    belongs_to :tariff, Tariff, type: :binary_id

    has_one :order, Order
    has_one :course, Course

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
