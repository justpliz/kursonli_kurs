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

# mix ecto.rollback --step 20 && mix ecto.migrate && mix run priv/repo/seeds.exs

# Create admin
{:ok, admin} = KursonliKurs.Context.Admins.create(%{login: "admin", password: "admin"})

# Create tariff
{:ok, tariff} =
  KursonliKurs.Context.Tariffs.create(%{
    name: "Пробный 1день",
    price: "0",
    days: 1,
    is_active: true
  })

# Create cities
{:ok, city_krg} =
  KursonliKurs.Context.Cities.create(%{
    name: "Караганда",
    short_name: "KRG",
    eng_name: "karaganda"
  })

{:ok, city_smsk} =
  KursonliKurs.Context.Cities.create(%{name: "Семей", short_name: "SMSK", eng_name: "semey"})

{:ok, city_ala} =
  KursonliKurs.Context.Cities.create(%{name: "Алматы", short_name: "ALA", eng_name: "almaty"})

# Create currencies
{:ok, usd} =
  KursonliKurs.Context.Currencies.create(%{
    name: "Американский доллар",
    short_name: "USD",
    color: "#c3efc9"
  })

{:ok, eur} =
  KursonliKurs.Context.Currencies.create(%{
    name: "Евро",
    short_name: "EUR",
    color: "#e7caf2"
  })

{:ok, rub} =
  KursonliKurs.Context.Currencies.create(%{
    name: "Российский рубль",
    short_name: "RUB",
    color: "#f5f0a8"
  })

# Create notifications
{:ok, _service_access} =
  KursonliKurs.Context.Notifications.create(%{
    name: "service_access",
    title: "Как оплатить тариф",
    description:
      "Чтобы оплатить тариф на сервисе KURS1.KZ вам необходимо будет отсканировать QR код представленный ниже через приложение kaspi.kz и после связаться с нашим менеджером по телефону + 7 (705) 555-08-11 и сообщить об оплате."
  })

{:ok, _expiration} =
  KursonliKurs.Context.Notifications.create(%{
    name: "expiration",
    title: "Осталось # дн.",
    description: "После окончания срока подписки, не будут доступны все разделы."
  })

{:ok, _instructions} =
  KursonliKurs.Context.Notifications.create(%{
    name: "instructions",
    title: "Внимание!",
    description:
      "Для начала работы нужно оплатить доступ к сервису KURS1.KZ. С Вами скоро свяжется менеджер!
    Как оплатить? Вы можете посмотреть в разделе Оплата, в левом меню."
  })

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
    city_id: city_krg.id,
    filial_address: "Жамбыла 4",
    filial_active_status: "active",
    organization_id: org1.id,
    tariff_id: tariff.id,
    paid_up_to: Timex.shift(Timex.now("Asia/Almaty"), days: tariff.days * 2)
  })

KursonliKurs.Context.Workers.create(%{
  password: KursonliKursWeb.GeneralHelper.hash_str("1234"),
  email: "odin@odin",
  filial_id: filial1.id
})

KursonliKurs.Context.Settings.create(%{
  filial_id: filial1.id,
  tags: ["true", "true"]
})

KursonliKurs.Context.Courses.create(%{
  value_for_sale: "-",
  value_for_purchase: "-",
  date: Timex.now("Asia/Almaty"),
  currency_id: usd.id,
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
    city_id: city_krg.id,
    filial_address: "Бейкер стрит",
    filial_active_status: "active",
    organization_id: org2.id,
    tariff_id: tariff.id,
    paid_up_to: Timex.shift(Timex.now("Asia/Almaty"), days: tariff.days * 2)
  })

KursonliKurs.Context.Workers.create(%{
  password: KursonliKursWeb.GeneralHelper.hash_str("1234"),
  email: "dva@dva",
  filial_id: filial2.id
})

KursonliKurs.Context.Settings.create(%{
  filial_id: filial2.id
})

KursonliKurs.Context.Courses.create(%{
  value_for_sale: "-",
  value_for_purchase: "-",
  date: Timex.now("Asia/Almaty"),
  currency_id: usd.id,
  filial_id: filial2.id
})

KursonliKurs.Context.Courses.create(%{
  value_for_sale: "-",
  value_for_purchase: "-",
  date: Timex.now("Asia/Almaty"),
  currency_id: eur.id,
  filial_id: filial2.id
})

KursonliKurs.Context.Courses.create(%{
  value_for_sale: "-",
  value_for_purchase: "-",
  date: Timex.now("Asia/Almaty"),
  currency_id: rub.id,
  filial_id: filial2.id
})
