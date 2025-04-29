defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ApiWeb.Auth.Pipeline
  end

  scope "/api", ApiWeb do
    pipe_through :api

    # Маршруты для аутентификации
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login

    resources "/tasks", TaskController, except: [:new, :edit]
    resources "/translations", TranslationController, only: [:create, :show]
    get "/languages", TranslationController, :get_languages
    post "/translate/poetic/router", TranslationController, :translate_poetic_router
  end

  scope "/api", ApiWeb do
    pipe_through [:api, :auth]

    # Защищенные маршруты, требующие аутентификации
    get "/user", AuthController, :user
  end

  # Health-check endpoint
  scope "/", ApiWeb do
    pipe_through :api
    get "/health", HealthController, :health
  end
end
