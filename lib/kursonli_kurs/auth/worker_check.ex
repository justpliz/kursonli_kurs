defmodule KursonliKurs.Auth.WorkerCheck do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: Enum.into(opts, %{})

  def call(conn, opts \\ []) do
    check_worker(conn, opts)
  end

  def check_worker(conn, _opts) do
    session_data = get_session(conn, :worker)

    if !is_nil(session_data) do
      conn
    else
      not_auth(conn)
    end
  end

  def index(conn, _params) do
    conn
    |> redirect(to: "/worker")
  end

  def not_auth(conn, message \\ "Вы не авторизованы") do
    conn
    |> put_status(:unauthorized)
    |> put_flash(:error, message)
    |> redirect(to: "/worker/login")
  end
end
