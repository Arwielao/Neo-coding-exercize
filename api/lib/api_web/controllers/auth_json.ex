defmodule ApiWeb.AuthJSON do
  alias Api.Accounts.User

  @doc """
  Рендеринг данных пользователя
  """
  def user(%{user: %User{} = user}) do
    %{
      id: user.id,
      username: user.username,
      email: user.email
    }
  end

  @doc """
  Рендеринг данных пользователя вместе с токеном
  """
  def user_token(%{user: %User{} = user, token: token}) do
    %{
      user: user(%{user: user}),
      token: token
    }
  end

  @doc """
  Рендеринг ошибок
  """
  def error(%{message: message}) do
    %{error: message}
  end

  def error(%{changeset: changeset}) do
    %{
      error: "Ошибка валидации",
      details: format_changeset_errors(changeset)
    }
  end

  # Форматирование ошибок валидации из changeset
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
