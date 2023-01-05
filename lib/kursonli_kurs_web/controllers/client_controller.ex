defmodule KursonliKursWeb.ClientController do
  use KursonliKursWeb, :controller
  action_fallback FallbackController

  alias KursonliKurs.Context.Users

  
  def login(conn, params) do
    login = params["login"]
    password = hash_str(params["password"])

    with {:ok, _client} <- Users.do_get(%{login: login, password: password}) do
      conn
      |> put_flash(:info, "Нормально короче все")
      |> redirect(to: "/")
    end
  end
end
