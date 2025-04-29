# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Temporarily comment out env loading
# if File.exists?(".env") do
#   DotenvParser.load_file(".env")
# end

config :api,
  ecto_repos: [Api.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :api, ApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  secret_key_base: System.get_env("SECRET_KEY_BASE", "Wt1Bdq22tYhp4VZqkzK718IZGQEP2JJo4B9q+a3DdK20q+Gnquzy9e3IHFbo1hi2"),
  render_errors: [
    formats: [json: ApiWeb.ErrorJSON],
    layout: false
  ],
  http: [port: String.to_integer(System.get_env("PORT", "4000") |> String.trim())],
  check_origin: false,
  pubsub_server: Api.PubSub,
  live_view: [signing_salt: "EzFifUP5"]

# Configure your database
config :api, Api.Repo,
  username: System.get_env("DATABASE_USERNAME", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  hostname: System.get_env("DATABASE_HOSTNAME", "localhost"),
  database: System.get_env("DATABASE_NAME", "api_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configuring Guardian for JWT Authentication
config :api, ApiWeb.Auth.Guardian,
  issuer: "api",
  secret_key: "F+KkCgUUy0OAPrw6zaPiYQCZ3sScnmJ60GBrcIbLzLlBMC80f8lHiBitQg1htGmG"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
