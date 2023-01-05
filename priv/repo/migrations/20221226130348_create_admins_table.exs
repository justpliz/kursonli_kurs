defmodule KursonliKurs.Repo.Migrations.CreateAdminsTable do
  use Ecto.Migration

  def change do
    create table(:admins, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :login, :string
      add :password, :string
    end
  end
end
