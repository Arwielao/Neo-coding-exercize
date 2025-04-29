defmodule ApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ApiWeb, :controller

  # Обработка ошибок валидации Ecto
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # Обработка ошибки "не найдено"
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ApiWeb.ErrorJSON)
    |> render(:"404")
  end

  # Обработка ошибки "не авторизован"
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: ApiWeb.ErrorJSON)
    |> render(:"401", %{message: "Необходима авторизация"})
  end

  # Обработка других ошибок
  def call(conn, {:error, _}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: ApiWeb.ErrorJSON)
    |> render(:"500")
  end
end
