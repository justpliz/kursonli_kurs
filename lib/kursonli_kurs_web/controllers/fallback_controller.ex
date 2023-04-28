defmodule KursonliKursWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use KursonliKursWeb, :controller

  alias KursonliKursWeb.ErrorView

  require Logger

  @doc """
  Not found fallback.
  """
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.html")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(302)
    |> redirect(to: "/worker/login")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(302)
    |> redirect(to: "/worker/login")
  end

  def call(conn, error) do
    Logger.warn("error_with_no_handler: #{inspect(error)}")

    conn
    |> put_status(500)
    |> put_view(ErrorView)
    |> render("500.html")
  end
end
