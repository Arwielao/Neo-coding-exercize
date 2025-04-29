defmodule ApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api

  # The session will be stored in the cookie and signed,
  # although :plug_init_mode defaults to :fetch_session
  @session_options [
    store: :cookie,
    key: "_api_key",
    signing_salt: "Czza24da"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :api,
    gzip: false,
    only: ApiWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # Добавляем поддержку CORS
  plug CORSPlug, origin: ["http://localhost:3000"]

  # The session will be stored in the cookie and signed,
  # although the default `:plug_init_mode` is `:fetch_session`
  plug Plug.Session, @session_options

  plug ApiWeb.Router
end
