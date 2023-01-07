defmodule KursonliKurs.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :login, :string
      add :email, :string
      add :phone, :string
      add :password, :string

      timestamps()
    end
  end
end
