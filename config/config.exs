# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kursonli_kurs,
  ecto_repos: [KursonliKurs.Repo],
  order_transfer: [:green, :red, :red_green],
  order_type: [:purchase, :sale],
  map_api_key: "f3dea359-6182-45eb-aeb7-82f6dd099f76",
  catalog_api_key: "rusvwm4868",
  scrapped: "https://mig.kz/"

# Configures the endpoint
config :kursonli_kurs, KursonliKursWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: KursonliKursWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: KursonliKurs.PubSub,
  live_view: [signing_salt: "vv/s4nSs"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :kursonli_kurs, KursonliKurs.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :kursonli_kurs, KursonliKursWeb.Gettext, default_locale: "rus", locales: ~w(rus kaz)

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
    --minify
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
