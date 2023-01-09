defmodule KursonliKurs.Repo.Migrations.AddUniqueIndex do
  use Ecto.Migration

  def change do
    create index("admins", [:login], unique: true)

    create index("cities", [:name, :short_name], unique: true)

    create index("currencies", [:name, :short_name], unique: true)

    create index("filials", [:name], unique: true)

    create index("organizations", [:name, :iin], unique: true)

    create index("tariffs", [:name], unique: true)

    create index("users", [:login, :email, :phone], unique: true)

    create index("workers", [:email, :phone], unique: true)
  end
end
