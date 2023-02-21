defmodule KursonliKurs.Model.Filial do
  use Ecto.Schema

  import Ecto.Changeset

  alias KursonliKurs.Model.Setting

  alias KursonliKurs.Model.{
    City,
    Organization,
    Tariff,
    Order,
    Course,
    Setting,
    CoursesHistory,
    Currency,
    Worker,
    FilialCurrency
  }

  @type t :: %__MODULE__{}
  @primary_key {:id, :binary_id, autogenerate: true}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name city_id organization_id fililal_address filial_active_status visible_status)a
  @optional_fields ~w(paid_up_to tariff_id)a

  schema "filials" do
    field :name, :string
    field :paid_up_to, :date, default: Timex.today()
    field :fililal_address, :string

    field :filial_active_status, ActiveStatus, default: "active"
    field :visible_status, :boolean, default: :false

    belongs_to :city, City
    belongs_to :organization, Organization, type: :binary_id
    belongs_to :tariff, Tariff

    has_one :order, Order
    has_many :course, Course
    has_one :courses_history, CoursesHistory

    # One-to-One
    has_one :worker, Worker
    has_one :setting, Setting

    # Many-to-Many
    many_to_many :currencies, Currency, join_through: "filials_currencies"
    has_one :filials_currencies, FilialCurrency

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
