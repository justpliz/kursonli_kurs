defmodule KursonliKursWeb.PlugLocal do
  import Plug.Conn
  def init(opts), do: Enum.into(opts, %{})

  def call(conn, _opts) do
    Gettext.put_locale(KursonliKursWeb.Gettext, get_current_lang(conn))

    conn
  end

  defp get_current_lang(conn) do
    if is_nil(get_session(conn, :lang)) do
      conn
      |> put_session(:lang, get_default_lang())

      get_default_lang()
    else
      get_session(conn, :lang)
    end
  end

  defp get_default_lang() do
    Application.get_env(:pulsar, KursonliKursWeb.Gettext)[:default_locale]
  end
end
