defmodule KursonliKurs.Repo.Migrations.CreateCoursesTable do
  use Ecto.Migration

  def change do
    create table(:courses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :value_for_sale, :string
      add :value_for_purchase, :string

      add :currency_id, references(:currencies, type: :uuid, on_delete: :nothing)
      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end