import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :vesseltracking_live,
  directIpListenerPort: 9998

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :vesseltracking_live, VesseltrackingLive.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "vesseltracking_live_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vesseltracking_live, VesseltrackingLiveWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "wgTc9uvz8uBEJd35dc+B30dx8VgBPx3bvQDKyoy96lrN7yA3SgbMj2Zvwu+npLco",
  server: false

# In test we don't send emails.
config :vesseltracking_live, VesseltrackingLive.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
