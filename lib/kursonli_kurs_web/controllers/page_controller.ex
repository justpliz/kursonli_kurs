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
      # |> IO.inspect()
      # |> check_true_diapason(scrapped_list)

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

      case setting.subdomen do
        "" ->
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

        _any ->
          conn
          |> redirect(to: "#{setting.sudomen}")
      end
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

  def scraping() do
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
          buy: Decimal.add(usd_buy, "0.5") |> Decimal.to_string() |> rounding_str,
          sale: Decimal.add(usd_sale, "-0.5") |> Decimal.to_string() |> rounding_str
        },
        %{
          currency: "EUR",
          buy: Decimal.add(eur_buy, "0.5") |> Decimal.to_string() |> rounding_str,
          sale: Decimal.add(eur_sale, "-0.5") |> Decimal.to_string() |> rounding_str
        },
        %{
          currency: "RUB",
          buy: Decimal.add(rub_buy, "0.05") |> Decimal.to_string() |> rounding_str,
          sale: Decimal.add(rub_sale, "-0.05") |> Decimal.to_string() |> rounding_str
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

  def find_best_courses(courses) do
    courses =
      courses
      # |> delete_old_courses
      |> Enum.map(&[&1.course, &1.date, &1.filial_id])

    {to_delete, _} =
      courses
      |> Enum.reduce({[], []}, fn [courses, _date, _id], {to_delete, untouch} ->
        Enum.reduce(courses, {to_delete, untouch}, fn
          %{short_name: name}, {to_delete, untouch} ->
            if name in to_delete and name not in untouch do
              {List.delete(to_delete, name), [name | untouch]}
            else
              {[name | to_delete], untouch}
            end
        end)
      end)

    courses_list =
      Enum.reduce(courses, [], fn [courses, date, id], acc ->
        [
          [
            Enum.reduce(courses, [], fn
              %{short_name: name} = course, acc ->
                if name in to_delete do
                  acc
                else
                  [course | acc]
                end
            end),
            date,
            id
          ]
          | acc
        ]
      end)
      |> Enum.map(fn [course, date, id] -> course |> Enum.map(&Map.put(&1, :id, id)) end)
  end

  def check_true_diapason(courses, scrapped) do
    usd_scrapped = Enum.find(scrapped, &(&1.currency == "USD"))
    usd_purchase = usd_scrapped.buy |> IO.inspect() |> String.to_float()
    usd_sale = usd_scrapped.sale |> String.to_float()

    # eur_scrapped = Enum.find(scrapped, &(&1.currency == "EUR"))
    # eur_sale = eur_scrapped.value_for_sale |> String.to_float()
    # eur_purchase = eur_scrapped.value_for_purchase |> String.to_float()

    # rub_scrapped = Enum.find(scrapped, &(&1.currency == "RUB"))
    # rub_sale = rub_scrapped.value_for_sale |> String.to_float()
    # rub_purchase = rub_scrapped.value_for_purchase |> String.to_float()

    courses
    |> Enum.map(
      &Enum.filter(&1.course, fn x ->
        IO.inspect(x)
        case x.short_name do
          "USD" ->
            value_for_sale = x.value_for_sale |> String.to_float()
            value_for_purchase = x.value_for_purchase |> String.to_float()

            if value_for_sale > usd_sale and value_for_sale < usd_purchase and
                 value_for_purchase > usd_sale and value_for_purchase < usd_purchase do
              &1
            else
              Map.put(&1.setting, :visible_website_status, false)
            end
            _any -> x
        end
      end)
    )
    # |> IO.inspect()
  end
end
