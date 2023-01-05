defmodule KursonliKurs.Repo.Migrations.CreateOrganizationsTable do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :password, :string
      add :photo, :string
      add :admin_id, references(:admins, type: :uuid, on_delete: :nothing)

      timestamps()
    end
  end
end
