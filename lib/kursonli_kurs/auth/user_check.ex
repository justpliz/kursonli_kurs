defmodule KursonliKurs.Auth.UserCheck do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: Enum.into(opts, %{})

  def call(conn, opts \\ []) do
    check_user(conn, opts)
  end

  def check_user(conn, _opts) do
    session_data = get_session(conn, :user)

    if not is_nil(session_data) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> redirect(to: "/user/login")
    end
  end

  def index(conn, _params) do
    conn
    |> redirect(to: "/user")
  end
end
