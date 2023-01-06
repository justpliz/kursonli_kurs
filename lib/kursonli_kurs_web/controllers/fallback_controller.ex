defmodule KursonliKursWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use KursonliKursWeb, :controller

  alias KursonliKursWeb.ErrorView

  require Logger

  @doc """
  Not found fallback
  """
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(MyErrorView)
    |> render("404.html")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(MyErrorView)
    |> render(:"403")
  end

  # enhanced error
  def call(conn, {:enhanced_error, error_opts}) do
    conn
    |> put_status(error_opts[:status_code] || 422)
    |> put_view(ErrorView)
    |> render("enhanced_error.json", %{error: error_opts})
  end

  # changeset validation errors
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("changeset_error.json", changeset: changeset)
  end

  # enhanced error handler
  def call(conn, {:error2, error}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error2.json", error: error)
  end

  def call(conn, error) do
    Logger.warn("error_with_no_handler: #{inspect(error)}")

    conn
    |> put_status(500)
    |> put_view(ErrorView)
    |> render("500.json")
  end
end
