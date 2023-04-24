defmodule KursonliKurs.Auth.AdminCheck do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: Enum.into(opts, %{})

  def call(conn, opts \\ []) do
    check_admin(conn, opts)
  end

  def check_admin(conn, _opts) do
    session_data = get_session(conn, :admin)

    if not is_nil(session_data) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> redirect(to: "/admin/login")
    end
  end

  def index(conn, _params) do
    conn
    |> redirect(to: "/admin/organization")
  end
end
