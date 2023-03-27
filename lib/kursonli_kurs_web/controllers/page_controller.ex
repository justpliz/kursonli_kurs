defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller
  action_fallback(KursonliKursWeb.FallbackController)

  alias KursonliKurs.Context.{Currencies, Filials, Settings, Cities}

  def redirect_almaty(conn, _params) do
    conn
    |> redirect(to: "/city?name=almaty")
  end

  def index(conn, params) do
    scrapped_list = scraping()

    with {:ok, city} <- Cities.do_get(eng_name: params["name"]) do
      city_list = get_count_city_with_active_filials()
      currency_list = Currencies.all() |> Enum.map(&%{short_name: &1.short_name})
      courses_list = Filials.get_filial_by_city(city.id)

      conn
      |> render("index.html",
        courses_list: courses_list,
        city_list: city_list,
        name: city.name,
        currency_list: currency_list,
        scrapped_list: scrapped_list
      )
    end
  end

  def personal_page(conn, %{"filial" => id}) do
    with {:ok, filial} <- Filials.do_get(id: id),
         {:ok, setting} <- Settings.do_get(filial_id: filial.id) do
      setting = setting |> PwHelper.Normalize.repo()
      courses_list = Filials.get_courses_list(filial.id)
      [x_coord, y_coord] = setting.coordinates
      city = Filials.get_city_by_filial_id(filial.id)
      photo_path = "http://#{conn.host}:#{conn.port}/#{setting.photo}"
      logo_path = "http://#{conn.host}:#{conn.port}/#{setting.logo}"

      conn
      |> render("personal_page.html",
        setting: setting,
        filial: filial,
        city_name: city.name,
        city_eng_name: city.eng_name,
        courses_list: courses_list,
        x_coord: x_coord,
        y_coord: y_coord,
        photo_path: photo_path,
        logo_path: logo_path
      )
    end
  end

  def get_count_city_with_active_filials() do
    Cities.all()
    |> Enum.map(fn city ->
      count =
        Filials.count(
          city_id: city.id,
          filial_active_status: :active,
          visible_course_status: true
        )

      %{name: city.name, count: count, eng_name: city.eng_name}
    end)
    |> Enum.sort_by(& &1.count, :desc)
    |> Enum.sort_by(&(&1.name == "Алматы"), :desc)
  end

  defp scraping() do
    with {:ok, response} = Application.get_env(:kursonli_kurs, :scrapped) |> HTTPoison.get() do
      [usd_buy, eur_buy, rub_buy, _, _, _, _] =
        Regex.scan(~r/<td .+"buy .+">.+<\/td>/, response.body)
        |> Enum.map(fn [x] ->
          String.replace(x, ~r/(<td .+"buy .+">|<\/td>)/, "")
        end)

      [usd_sale, eur_sale, rub_sale, _, _, _, _] =
        Regex.scan(~r/<td .+"sell .+">.+<\/td>/, response.body)
        |> Enum.map(fn [x] ->
          String.replace(x, ~r/(<td .+"sell .+">|<\/td>)/, "")
        end)

      [
        %{
          currency: "USD",
          buy: Decimal.add(usd_buy, "0.5") |> Decimal.to_string(),
          sale: Decimal.add(usd_sale, "-0.5") |> Decimal.to_string()
        },
        %{
          currency: "EUR",
          buy: Decimal.add(eur_buy, "0.5") |> Decimal.to_string(),
          sale: Decimal.add(eur_sale, "-0.5") |> Decimal.to_string()
        },
        %{
          currency: "RUB",
          buy: Decimal.add(rub_buy, "0.05") |> Decimal.to_string(),
          sale: Decimal.add(rub_sale, "-0.05") |> Decimal.to_string()
        }
      ]
    end
  end

  def instruction_rus(conn, _params) do
    conn
    |> redirect(to: "/pdfs/instruction_kurs-online_rus.pdf")
  end

  def instruction_kaz(conn, _params) do
    conn
    |> redirect(to: "/pdfs/instruction_kurs-online_kaz.pdf")
  end
end
