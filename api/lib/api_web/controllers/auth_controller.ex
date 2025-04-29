defmodule ApiWeb.AuthController do
  use ApiWeb, :controller

  alias Api.Accounts
  alias Api.Accounts.User
  alias ApiWeb.Auth.Guardian

  action_fallback ApiWeb.FallbackController

  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, %User{} = user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        conn
        |> put_status(:created)
        |> json(ApiWeb.AuthJSON.user_token(%{user: user, token: token}))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ApiWeb.AuthJSON.error(%{changeset: changeset}))
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        conn
        |> put_status(:ok)
        |> json(ApiWeb.AuthJSON.user_token(%{user: user, token: token}))
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(ApiWeb.AuthJSON.error(%{message: "Неверный email или пароль"}))
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(ApiWeb.AuthJSON.error(%{message: "Пользователь с таким email не найден"}))
    end
  end

  def user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    conn
    |> put_status(:ok)
    |> json(ApiWeb.AuthJSON.user(%{user: user}))
  end
end
