defmodule KursonliKurs.Model.Setting do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  alias KursonliKurs.Model.Filial
  alias KursonliKursWeb.GeneralHelper

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(tags coordinates address email photo logo filial_id visible_website_status visible_course_status)a
  @optional_fields ~w(phones license qualities description colors slug url firm_id promo link shedule_type auto_update shedule_period)a

  schema "settings" do
    field :address, :string

    field :tags, {:array, :string}, default: ["false", "false"]
    field :coordinates, {:array, :string}, default: ["76.944551", "43.239521"]
    field :firm_id, :string
    field :logo, :string, default: "images/logo/default_logo.jpg"
    field :photo, :string, default: "images/photo/default_photo.jpg"
    field :license, :string, default: ""
    field :email, :string, default: "email@email.kz"
    field :description, :string, default: "Описание будет добавлено позже"

    field :shedule_type, ScheduleType, default: "nine_twenty"
    field :auto_update, :boolean, default: false
    field :shedule_period, :integer

    field :slug, :string, default: ""
    field :url, :string, default: ""
    field :link, FilialLink, default: :filial_id

    field :visible_website_status, :boolean, default: false
    field :visible_course_status, :boolean, default: false

    field :promo, :map,
      default: %{
        promo1: "",
        promo2: ""
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
        color_qualities_text: "#ffffff",
        color_logo: GeneralHelper.generate_random_color()
      }

    belongs_to :filial, Filial, type: :binary_id
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:shedule_period, 1..120)
  end
end
