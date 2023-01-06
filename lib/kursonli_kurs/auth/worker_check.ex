defmodule KursonliKurs.Auth.WorkerCheck do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: Enum.into(opts, %{})

  def call(conn, opts \\ []) do
    check_worker(conn, opts)
  end

  def check_worker(conn, _opts) do
    session_data = get_session(conn, :worker)

    if not is_nil(session_data) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> redirect(to: "/worker/login")
    end
  end

  def index(conn, _params) do
    conn
    |> redirect(to: "/worker")
  end
end
