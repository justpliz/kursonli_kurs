defmodule KursonliKurs.Repo.Migrations.CreateCoursesTable do
  use Ecto.Migration

  def change do
    create table(:courses, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :first_name, :string
      add :last_name, :string
      add :password, :string
      add :phone, :string
      add :filial_id, references(:filials, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
