defmodule KursonliKurs.Repo.Migrations.CreateNotificationTable do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :name, :string
      add :title, :string
      add :description, :text
      add :photo, :string
    end
  end
end
