defmodule KursonliKurs.Repo.Migrations.CreateOrganizationsTable do
  use Ecto.Migration

  def change do
    ActiveStatus.create_type()

    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :iin, :string
      add :org_active_status, :active_status

      add :admin_id, references(:admins, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index("organizations", [:name, :iin], unique: true)
    create index(:organizations, [:name])
  end
end
