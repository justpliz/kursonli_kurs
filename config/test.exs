import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :kursonli_kurs, KursonliKurs.Repo,
  username: "lar",
  password: "NOJo7oHK2b",
  hostname: "192.168.0.2",
  database: "kursonli_kurs_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kursonli_kurs, KursonliKursWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "uqIXu4oRV2xfnLAulCCyLNh0t2G8E2fIUqZ5tLphw6pc9sWgD49vZl9H8AUq9x2O",
  server: false

# In test we don't send emails.
config :kursonli_kurs, KursonliKurs.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
