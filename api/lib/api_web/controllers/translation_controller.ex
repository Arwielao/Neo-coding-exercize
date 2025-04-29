defmodule ApiWeb.TranslationController do
  use ApiWeb, :controller

  alias Api.Translations
  alias Api.Translations.Translation
  alias Api.Services.AIService

  action_fallback ApiWeb.FallbackController

  # OpenAI API URL
  @openai_api_url "https://api.openai.com/v1/chat/completions"
  # Здесь добавьте ваш OpenAI API KEY в следующем формате: "Bearer sk-xxxxxxxx"
  # НЕ ХРАНИТЕ КЛЮЧИ В КОДЕ В РЕАЛЬНЫХ ПРОЕКТАХ!
  # В реальном проекте используйте переменные окружения или конфигурацию
  @openai_api_key "Bearer YOUR_OPENAI_API_KEY"
  # URL для доступа к языкам API перевода
  @translation_api_url "https://api.translation.example.com"

  def index(conn, _params) do
    translations = Translations.list_translations()
    render(conn, :index, translations: translations)
  end

  def create(conn, %{"translation" => translation_params}) do
    with {:ok, %Translation{} = translation} <- Translations.create_translation(translation_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.translation_path(conn, :show, translation))
      |> render(:show, translation: translation)
    end
  end

  def show(conn, %{"id" => id}) do
    translation = Translations.get_translation!(id)
    render(conn, :show, translation: translation)
  end

  def update(conn, %{"id" => id, "translation" => translation_params}) do
    translation = Translations.get_translation!(id)

    with {:ok, %Translation{} = translation} <- Translations.update_translation(translation, translation_params) do
      render(conn, :show, translation: translation)
    end
  end

  def delete(conn, %{"id" => id}) do
    translation = Translations.get_translation!(id)

    with {:ok, %Translation{}} <- Translations.delete_translation(translation) do
      send_resp(conn, :no_content, "")
    end
  end

  # Получить список поддерживаемых языков
  def supported_languages(conn, _params) do
    case HTTPoison.get("#{@translation_api_url}/languages") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        languages = Jason.decode!(body)
        json(conn, %{languages: languages})

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Ошибка при получении списка языков: #{reason}"})
    end
  end

  # Получение списка языков
  def get_languages(conn, _params) do
    languages = %{
      "ru" => "Русский",
      "en" => "Английский",
      "fr" => "Французский",
      "de" => "Немецкий",
      "es" => "Испанский",
      "it" => "Итальянский",
      "zh" => "Китайский",
      "ja" => "Японский"
    }

    json(conn, languages)
  end

  # Обычный перевод
  def translate(conn, %{"text" => text, "target_lang" => target_lang}) do
    case do_translation(text, target_lang, false) do
      {:ok, translation} ->
        json(conn, %{translation: translation})

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
    end
  end

  # Поэтический перевод
  def translate_poetic(conn, %{"text" => text, "target_lang" => target_lang}) do
    case do_translation(text, target_lang, true) do
      {:ok, translation} ->
        json(conn, %{translation: translation})

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
    end
  end

  # Перевод и поэтический перевод через Hugging Face
  def translate_hf(conn, %{"text" => text, "from_lang" => from_lang, "to_lang" => to_lang}) do
    case AIService.translate_text(text, from_lang, to_lang) do
      {:ok, translation} ->
        json(conn, %{
          original_text: text,
          translated_text: translation,
          from_lang: from_lang,
          to_lang: to_lang
        })

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
    end
  end

  # Перевод через Hugging Face Router API
  def translate_router(conn, %{"text" => text, "from_lang" => from_lang, "to_lang" => to_lang}) do
    case AIService.translate_with_router(text, from_lang, to_lang) do
      {:ok, translation} ->
        json(conn, %{
          original_text: text,
          translated_text: translation,
          from_lang: from_lang,
          to_lang: to_lang
        })

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
    end
  end

  # Перевод и поэтический перевод через Router API
  def translate_poetic_router(conn, %{"text" => text, "from_lang" => from_lang, "to_lang" => to_lang}) do
    case AIService.translate_and_poetize_with_router(text, from_lang, to_lang) do
      {:ok, result} ->
        json(conn, result)

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: reason})
    end
  end

  # Функция для перевода с использованием OpenAI API
  defp do_translation(text, target_lang, poetic) do
    language_name = get_language_name(target_lang)

    # Создаем системную инструкцию и сообщение пользователя
    system_instruction = if poetic do
      "Ты профессиональный переводчик и поэт. Переводи текст и создавай поэтические версии как на языке оригинала, так и на языке перевода."
    else
      "Ты профессиональный переводчик. Переводи текст точно и корректно."
    end

    user_message = if poetic do
      "Переведи следующий текст на #{language_name}, а затем создай поэтическую версию как исходного текста, так и перевода: #{text}"
    else
      "Переведи следующий текст на #{language_name}: #{text}"
    end

    # Создаем тело запроса
    body = %{
      model: "gpt-3.5-turbo",
      messages: [
        %{role: "system", content: system_instruction},
        %{role: "user", content: user_message}
      ],
      temperature: poetic && 0.7 || 0.3
    }

    # Заголовки запроса
    headers = [
      {"Authorization", @openai_api_key},
      {"Content-Type", "application/json"}
    ]

    # Отправляем запрос к OpenAI API
    case HTTPoison.post(@openai_api_url, Jason.encode!(body), headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        # Парсим ответ
        response = Jason.decode!(response_body)
        translation = response["choices"]
                      |> List.first()
                      |> Map.get("message")
                      |> Map.get("content")

        {:ok, translation}

      {:ok, %{status_code: status_code, body: body}} ->
        error = Jason.decode!(body)
        {:error, "API error (#{status_code}): #{error["error"]["message"]}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Network error: #{reason}"}
    end
  end

  # Получаем полное название языка по коду
  defp get_language_name(lang_code) do
    case lang_code do
      "ru" -> "русский"
      "en" -> "английский"
      "fr" -> "французский"
      "de" -> "немецкий"
      "es" -> "испанский"
      "it" -> "итальянский"
      "zh" -> "китайский"
      "ja" -> "японский"
      _ -> "английский" # По умолчанию
    end
  end
end
