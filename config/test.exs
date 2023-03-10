import Config

config :ash, :disable_async?, true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :terrible, Terrible.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "terrible_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :terrible, TerribleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YokyGNGikhXRP5GsWaBhwmXg26jYOeJxAWNa1hscH8oxpOGxHLASaSDA1D7jp5fK",
  server: false

# In test we don't send emails.
config :terrible, Terrible.Mailer, adapter: Swoosh.Adapters.Test

config :terrible,
  token_signing_secret: "/kdFJFGsvqHH7EL5jvN2z0AAYb7mPsWEDtL0+O/8i86p6wwJ6S6HGa9kdyVygaKg"

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
