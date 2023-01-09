defmodule KursonliKurs.Model.Order do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.{Organization, User, Filial, Worker, Currency}

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(date rate volume terms
  transfer limit type)a
  @optional_fields ~w()a

  schema "orders" do
    field :date, :naive_datetime
    field :rate, :string
    field :volume, :string
    field :terms, :string
    field :transfer, :string
    field :limit, :string

    field :type, OrderType, default: "sale"

    has_one :user, User
    has_one :organization, Organization
    has_one :filial, Filial
    has_one :worker, Worker
    has_one :currency, Currency
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
