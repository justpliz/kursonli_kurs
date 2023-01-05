defmodule KursonliKursWeb.PageController do
  use KursonliKursWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
