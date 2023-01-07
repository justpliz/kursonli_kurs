defmodule KursonliKursWeb.UserController do
  use KursonliKursWeb, :controller
  action_fallback KursonliKursWeb.FallbackController

  alias KursonliKurs.Context.{Users}

  @doc """
  GET /user/login
  """
  def login_form(conn, _params) do
    conn
    |> render("user_login_form.html")
    |> halt()
  end

  @doc """
  POST /user/login
  """
  def login_form_submit(conn, params) do
    opts = [
      login: params["login"],
      password: hash_str(params["password"])
    ]

    case Users.do_get(opts) do
      {:ok, user} ->
        conn
        |> put_session(:user, %{
          id: user.id,
          login: user.login,
          phone: user.phone,
          email: user.email
        })
        |> put_flash(:info, "Добро пожаловать #{user.login}")
        |> redirect(to: "/user")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Невеный логин или пароль")
        |> redirect(to: "/user/login")
    end
  end

  @doc """
  GET /user/register
  """
  def register_form(conn, _params) do
    conn
    |> render("user_register_form.html")
  end

  @doc """
  POST /user/register
  TODO: check pass == re_pass
  TODO: check exists user
  """
  def register_form_submit(conn, params) do
    opts = %{
      login: params["login"],
      phone: params["phone"],
      email: params["email"],
      password: hash_str(params["password"])
    }

    if params["password"] != params["re_password"],
    do:
      conn
      |> put_flash(:error, "Несовпадают пароли")
      |> redirect(to: "/user/register")

    with {:ok, _user} <- Users.create(opts) do
      conn
      |> put_flash(:info, "Пользователь успешно зарегестрирован")
      |> redirect(to: "/user")
    end
  end

  @doc """
  GET /user/logout
  """
  def user_logout(conn, _params) do
    conn
    |> delete_session(:user)
    |> redirect(to: "/user/login")
  end

  @doc """
  GET /user/
  """
  def index(conn, _params) do
    conn
    |> render("user_index.html")
  end

  @doc """
  GET /user/update_pass
  """
  def update_pass(conn, _params) do
    conn
    |> render("user_update_pass.html")
  end

  @doc """
  POST /user/update_pass
  """
  def update_pass_submit(conn, params) do
    id = get_session(conn, :user).id
    old_pass = hash_str(params["old_pass"])
    new_pass = hash_str(params["new_pass"])
    re_new_pass = hash_str(params["re_new_pass"])

    if new_pass != re_new_pass,
      do:
        conn
        |> put_flash(:error, "Несовпадают пароли")
        |> redirect(to: "/user/update_pass")

    with {:ok, user} <- Users.do_get(id: id, password: old_pass),
         {:ok, _user} <- Users.update(user, %{password: new_pass}) do
      conn
      |> put_flash(:info, "Пароль успешно изменен")
      |> redirect(to: "/user")
    end
  end
end
