defmodule KursonliKurs.Repo.Migrations.AddShedulePeriod do
  use Ecto.Migration

  def change do
    rename table("settings"), :type, to: :shedule_type

    alter table(:settings) do
      add :shedule_period, :integer
    end
  end
end
