defmodule KursonliKurs.Model.Notification do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @timestamps_opts [type: :utc_datetime]
  @required_fields ~w(name title description)a
  @optional_fields ~w()a

  schema "notifications" do
    field :name, :string
    field :title, :string
    field :description, :string
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
