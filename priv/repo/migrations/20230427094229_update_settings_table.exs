defmodule KursonliKurs.Repo.Migrations.UpdateSettingsTable do
  use Ecto.Migration

  def change do
    FilialLink.create_type()

    alter table(:filials) do
      remove :filial_address
      remove :visible_course_status
    end

    alter table(:settings) do
      add :link, :filial_link
      add :visible_course_status, :boolean, default: :false, null: false
    end
  end
end
