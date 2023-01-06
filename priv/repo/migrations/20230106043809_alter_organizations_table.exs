defmodule KursonliKurs.Repo.Migrations.AlterOrganizationsTable do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      remove :password

      add :iin, :string
    end

  end
end
