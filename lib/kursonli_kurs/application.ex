defmodule KursonliKurs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      KursonliKurs.Repo,
      # Start the Telemetry supervisor
      KursonliKursWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: KursonliKurs.PubSub},
      # Start the Endpoint (http/https)
      KursonliKursWeb.Endpoint,
      # Start a worker by calling: KursonliKurs.Worker.start_link(arg)
      # {KursonliKurs.Worker, arg}
      %{
        id: KursonliKurs.EtsStorage.Chat,
        start: {KursonliKurs.EtsStorage.Chat, :start_link, []}
      },
      %{
        id: KursonliKurs.EtsStorage.UserOnline,
        start: {KursonliKurs.EtsStorage.UserOnline, :start_link, []}
      },
      %{
        id: KursonliKurs.EtsStorage.SessionWorker,
        start: {KursonliKurs.EtsStorage.SessionWorker, :start_link, []}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    # KursonliKurs.EtsStorage.Chat.create()
    # KursonliKurs.EtsStorage.UserOnline.create()
    opts = [strategy: :one_for_one, name: KursonliKurs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KursonliKursWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
