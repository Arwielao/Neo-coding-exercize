defmodule ApiWeb.HealthController do
  use ApiWeb, :controller

  # Эндпойнт для проверки работоспособности сервиса
  def health(conn, _params) do
    # Возвращаем простой JSON с кодом 200
    json(conn, %{status: "ok"})
  end
end
