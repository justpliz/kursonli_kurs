defmodule KursonliKurs.Repo.Migrations.AddSchedule do
  use Ecto.Migration

  def change do
    ScheduleType.create_type()

    alter table(:settings) do
      add :type, ScheduleType
      add :auto_update, :boolean, default: false, null: false
    end
  end
end
