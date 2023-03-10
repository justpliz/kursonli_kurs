defmodule KursonliKurs.Model.Setting do
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(tags coordinates description email photo logo filial_id visible_website_status)a
  @optional_fields ~w(schedule phones license qualities colors subdomen firm_id promo)a

  schema "settings" do
    field :tags, {:array, :string}, default: ["false", "false"]
    field :coordinates, {:array, :string}, default: ["76.944551", "43.239521"]
    field :firm_id, :string
    field :logo, :string, default: "images/logo/default_logo.jpg"
    field :photo, :string, default: "images/photo/default_photo.jpg"
    field :license, :string, default: ""
    field :email, :string, default: "email@email.kz"
    field :subdomen, :string, default: ""
    field :description, :string, default: "Описание будет добавлено позже"
    field :visible_website_status, :boolean, default: :false

    field :promo, :map,
      default: %{
        promo1: "",
        promo2: "",
      }

    field :schedule, :map,
      default: %{
        schedule_other: "Дополнительная информация",
        schedule_sunday: "-",
        schedule_saturday: "-",
        schedule_weekdays: "-"
      }

    field :phones, :map,
      default: %{
        phone1: "",
        phone2: "",
        phone3: "",
        phone_for_header: ""
      }

    field :qualities, :map,
      default: %{quality1: "1 качество", quality2: "2 качество", quality3: "3 качество"}

    field :colors, :map,
      default: %{
        color_currency: "#000000",
        color_qualities: "#000000",
        color_scoreboard: "#000000",
        color_qualities_text: "#ffffff"
      }

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
