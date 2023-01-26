# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KursonliKurs.Repo.insert!(%KursonliKurs.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
{:ok, admin} = KursonliKurs.Context.Admins.create(%{login: "admin", password: "admin"})
{:ok, city} = KursonliKurs.Context.Cities.create(%{name: "Караганда", short_name: "KRG"})
KursonliKurs.Context.Cities.create(%{name: "Семей", short_name: "SMSK"})
KursonliKurs.Context.Currencies.create(%{name: "Американский доллар", short_name: "USD"})
KursonliKurs.Context.Currencies.create(%{name: "Евро", short_name: "EUR"})

# Create Org1
{:ok, org1} =
  KursonliKurs.Context.Organizations.create(%{
    name: "Org_odin",
    iin: "123456789",
    admin_id: admin.id,
    org_active_status: :active
  })

{:ok, filial1} =
  KursonliKurs.Context.Filials.create(%{
    name: "Odin1",
    city_id: city.id,
    organization_id: org1.id
  })

KursonliKurs.Context.Workers.create(%{
  phone: "+7 (707) 777-77-77",
  password: KursonliKursWeb.GeneralHelper.hash_str("1234"),
  email: "odin@odin",
  filial_id: filial1.id
})

KursonliKurs.Context.Settings.create(%{
  coordinates: ["0", "0"],
  address: "address 1",
  filial_id: filial1.id
})

# Create Org2
{:ok, org2} =
  KursonliKurs.Context.Organizations.create(%{
    name: "Org_dva",
    iin: "987654321",
    admin_id: admin.id,
    org_active_status: :active
  })

{:ok, filial2} =
  KursonliKurs.Context.Filials.create(%{
    name: "Dva1",
    city_id: city.id,
    organization_id: org2.id
  })

KursonliKurs.Context.Workers.create(%{
  phone: "+7 (777) 777-77-77",
  password: KursonliKursWeb.GeneralHelper.hash_str("1234"),
  email: "dva@dva",
  filial_id: filial2.id
})

KursonliKurs.Context.Settings.create(%{
  coordinates: ["0", "0"],
  address: "address 2",
  filial_id: filial2.id
})
