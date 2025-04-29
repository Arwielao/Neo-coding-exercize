defmodule Api.Services.AIService do
  @moduledoc """
  Сервис для мультиязычного перевода и генерации стихов.
  """

  # Добавим логирование для отладки
  require Logger

  # Базовый URL для Hugging Face Inference API (corrected)
  @hf_api_url "https://api-inference.huggingface.co/models"

  # API ключ для Hugging Face
  @hf_api_key "***REMOVED***"

  # Модели для перевода специфичных языковых пар
  @translation_models %{
    "ru-en" => "Helsinki-NLP/opus-mt-ru-en",
    "en-ru" => "Helsinki-NLP/opus-mt-en-ru",
    "ru-fr" => "Helsinki-NLP/opus-mt-ru-fr",
    "fr-ru" => "Helsinki-NLP/opus-mt-fr-ru",
    "ru-de" => "Helsinki-NLP/opus-mt-ru-de",
    "de-ru" => "Helsinki-NLP/opus-mt-de-ru",
    "en-fr" => "Helsinki-NLP/opus-mt-en-fr",
    "fr-en" => "Helsinki-NLP/opus-mt-fr-en",
    "en-de" => "Helsinki-NLP/opus-mt-en-de",
    "de-en" => "Helsinki-NLP/opus-mt-de-en",
    # Запасная многоязычная модель
    "multi" => "facebook/nllb-200-distilled-600M"
  }

  # Модель для генерации поэзии
  @poetry_model "gpt2"

  # Поддерживаемые языки и их коды
  @supported_languages %{
    "en" => "English",
    "ru" => "Russian",
    "ja" => "Japanese",
    "zh" => "Chinese",
    "ko" => "Korean",
    "fr" => "French",
    "de" => "German",
    "es" => "Spanish",
    "it" => "Italian",
    "pt" => "Portuguese"
  }

  # Сопоставление кодов языков для модели NLLB
  @nllb_language_codes %{
    "en" => "eng_Latn",
    "ru" => "rus_Cyrl",
    "fr" => "fra_Latn",
    "de" => "deu_Latn",
    "es" => "spa_Latn",
    "it" => "ita_Latn",
    "zh" => "zho_Hans",
    "ja" => "jpn_Jpan",
    "ko" => "kor_Hang",
    "pt" => "por_Latn"
  }

  # Яндекс API (оставляем как альтернативу)
  @yandex_api_url "https://translate.api.cloud.yandex.net/translate/v2/translate"
  @yandex_api_key "ваш_ключ_яндекс"
  @folder_id "ваш_folder_id"

  # URL для Hugging Face Novita Router API
  @hf_router_url "https://router.huggingface.co/novita/v3/openai/chat/completions"

  @doc """
  Переводит текст и создает стихи на обоих языках.
  """
  def translate_and_poetize(text, from_lang, to_lang) do
    with {:ok, translated_text} <- translate_text(text, from_lang, to_lang),
         {:ok, source_poem} <- generate_poem(text, from_lang),
         {:ok, target_poem} <- generate_poem(translated_text, to_lang) do
      {:ok, %{
        original_text: text,
        translated_text: translated_text,
        source_poem: source_poem,
        target_poem: target_poem,
        from_lang: from_lang,
        to_lang: to_lang
      }}
    else
      {:error, reason} -> handle_api_error(reason)
    end
  end

  @doc """
  Выполняет перевод текста используя модели Hugging Face.
  """
  def translate_text(text, from_lang, to_lang) do
    # Формируем ключ для поиска специфичной модели перевода
    lang_pair = "#{from_lang}-#{to_lang}"

    # Проверяем, существует ли модель для данной языковой пары
    if Map.has_key?(@translation_models, lang_pair) do
      # Есть специфичная модель перевода
      model = @translation_models[lang_pair]
      Logger.info("Using specific translation model: #{model}")

      # Делаем запрос к специфичной модели
      make_hf_request(model, %{
        inputs: text
      })
    else
      # Используем многоязычную модель как запасной вариант
      Logger.info("Using multilingual model for #{from_lang} to #{to_lang}")

      # Получаем коды языков для NLLB модели
      src_lang = Map.get(@nllb_language_codes, from_lang, "eng_Latn")
      tgt_lang = Map.get(@nllb_language_codes, to_lang, "eng_Latn")

      # Делаем запрос к многоязычной модели
      make_hf_request(@translation_models["multi"], %{
        inputs: text,
        parameters: %{
          src_lang: src_lang,
          tgt_lang: tgt_lang
        }
      })
    end
  end

  @doc """
  Генерирует стихотворение на указанном языке.
  """
  def generate_poem(text, lang) do
    language_name = @supported_languages[lang]

    prompt = case lang do
      "ja" ->
        """
        以下のテキストを詩に変換してください:
        #{text}

        詩:
        """
      "zh" ->
        """
        请将以下文本转换为诗歌:
        #{text}

        诗歌:
        """
      "ko" ->
        """
        다음 텍스트를 시로 변환하십시오:
        #{text}

        시:
        """
      _ ->
        """
        Generate two four-line stanzas based on the following text in #{language_name}:
        #{text}

        Poem:
        """
    end

    make_hf_request(@poetry_model, %{
      inputs: prompt,
      parameters: %{
        max_length: 200,
        temperature: 0.9,
        top_p: 0.9,
        repetition_penalty: 1.2,
        do_sample: true
      }
    })
  end

  @doc """
  Возвращает список поддерживаемых языков.
  """
  def supported_languages do
    @supported_languages
  end

  @doc """
  Выполняет запрос к Hugging Face Inference API.
  """
  def make_hf_request(model, payload) do
    url = "#{@hf_api_url}/#{model}"

    headers = [
      {"Authorization", "Bearer #{@hf_api_key}"},
      {"Content-Type", "application/json"}
    ]

    Logger.info("Sending request to #{url}")
    Logger.debug("Payload: #{inspect(payload)}")

    case HTTPoison.post(url, Jason.encode!(payload), headers) do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.debug("Response body: #{body}")
        parse_hf_response(body, model)

      {:ok, %{status_code: status_code, body: body}} ->
        Logger.error("HF API error: #{status_code} - #{body}")
        {:error, "API error (#{status_code}): #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}
    end
  end

  @doc """
  Парсит ответ от Hugging Face API в зависимости от модели.
  """
  def parse_hf_response(body, model) do
    try do
      response = Jason.decode!(body)

      cond do
        # Если ответ является строкой
        is_binary(response) ->
          {:ok, response}

        # Если ответ является массивом строк
        is_list(response) && length(response) > 0 && is_binary(List.first(response)) ->
          {:ok, List.first(response)}

        # Для моделей перевода Helsinki-NLP
        String.contains?(model, "Helsinki-NLP/opus-mt") ->
          translation = response
                       |> Map.get("translation_text", "")
          {:ok, translation}

        # Для моделей NLLB
        String.contains?(model, "nllb") ->
          translation = response
                       |> Map.get("translation_text", "")
          {:ok, translation}

        # Для моделей генерации текста
        String.contains?(model, "gpt2") ->
          generated = response
                     |> Map.get("generated_text", "")
          {:ok, generated}

        # Общий случай - попытаться извлечь текст из первого элемента
        true ->
          if is_map(response) do
            translation = Map.get(response, "translation_text",
                        Map.get(response, "generated_text",
                        Map.get(response, "text", "")))
            {:ok, translation}
          else
            {:ok, inspect(response)}
          end
      end
    rescue
      e ->
        Logger.error("Error parsing HF response: #{inspect(e)}")
        {:error, "Error parsing response: #{inspect(e)}"}
    end
  end

  @doc """
  Обрабатывает ошибки при работе с AI API.
  """
  def handle_api_error(reason) do
    Logger.error("Translation API error: #{inspect(reason)}")
    {:error, reason}
  end

  @doc """
  Перевод через Яндекс.Переводчик API
  """
  def translate_with_yandex(text, from_lang, to_lang) do
    payload = %{
      texts: [text],
      sourceLanguageCode: from_lang,
      targetLanguageCode: to_lang,
      folderId: @folder_id
    }

    headers = [
      {"Authorization", "Api-Key #{@yandex_api_key}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(@yandex_api_url, Jason.encode!(payload), headers) do
      {:ok, %{status_code: 200, body: body}} ->
        response = Jason.decode!(body)
        translation = response["translations"]
                     |> List.first()
                     |> Map.get("text", "")
        {:ok, translation}

      {:ok, %{status_code: status_code, body: body}} ->
        Logger.error("Yandex API error: #{status_code} - #{body}")
        {:error, "API error (#{status_code}): #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Yandex error: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}
    end
  end

  @doc """
  Выполняет перевод с использованием модели через Hugging Face Router API
  """
  def translate_with_router(text, from_lang, to_lang) do
    to_lang_name = @supported_languages[to_lang]

    # Формируем сообщение пользователя для перевода
    prompt = "Переведи следующий текст с #{@supported_languages[from_lang]} на #{to_lang_name}, без дополнительных комментариев: \"#{text}\""

    # Формируем тело запроса в формате OpenAI Chat API
    payload = %{
      messages: [
        %{role: "user", content: prompt}
      ],
      model: "deepseek/deepseek-v3-0324"  # Используем модель, которая работает в запросе
    }

    headers = [
      {"Authorization", "Bearer #{@hf_api_key}"},
      {"Content-Type", "application/json"}
    ]

    Logger.info("Sending request to Router API for translation")

    case HTTPoison.post(@hf_router_url, Jason.encode!(payload), headers) do
      {:ok, %{status_code: 200, body: body}} ->
        response = Jason.decode!(body)

        # Извлекаем ответ из формата OpenAI Chat API
        translation = response["choices"]
                     |> List.first()
                     |> Map.get("message")
                     |> Map.get("content")

        {:ok, translation}

      {:ok, %{status_code: status_code, body: body}} ->
        Logger.error("HF Router API error: #{status_code} - #{body}")
        {:error, "API error (#{status_code}): #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}
    end
  end

  @doc """
  Создает поэтическую версию текста на указанном языке через Router API
  """
  def generate_poem_with_router(text, lang) do
    language_name = @supported_languages[lang]

    # Формируем запрос на генерацию двух четверостиший
    prompt = """
    Generate two four-line stanzas in #{language_name}, based on the following text.
    Write only the poem, without additional comments:

    #{text}
    """

    # Формируем тело запроса в формате OpenAI Chat API
    payload = %{
      messages: [
        %{role: "user", content: prompt}
      ],
      model: "deepseek/deepseek-v3-0324",
      temperature: 0.8  # Увеличиваем креативность для поэзии
    }

    headers = [
      {"Authorization", "Bearer #{@hf_api_key}"},
      {"Content-Type", "application/json"}
    ]

    Logger.info("Sending request to Router API for poetry generation")

    case HTTPoison.post(@hf_router_url, Jason.encode!(payload), headers) do
      {:ok, %{status_code: 200, body: body}} ->
        response = Jason.decode!(body)

        # Извлекаем ответ из формата OpenAI Chat API
        poem = response["choices"]
              |> List.first()
              |> Map.get("message")
              |> Map.get("content")

        {:ok, poem}

      {:ok, %{status_code: status_code, body: body}} ->
        Logger.error("HF Router API error: #{status_code} - #{body}")
        {:error, "API error (#{status_code}): #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect(reason)}")
        {:error, "Network error: #{inspect(reason)}"}
    end
  end

  @doc """
  Переводит текст и создает стихи через Router API
  """
  def translate_and_poetize_with_router(text, from_lang, to_lang) do
    with {:ok, translated_text} <- translate_with_router(text, from_lang, to_lang),
         {:ok, source_poem} <- generate_poem_with_router(text, from_lang),
         {:ok, target_poem} <- generate_poem_with_router(translated_text, to_lang) do
      {:ok, %{
        original_text: text,
        translated_text: translated_text,
        source_poem: source_poem,
        target_poem: target_poem,
        from_lang: from_lang,
        to_lang: to_lang
      }}
    else
      {:error, reason} -> handle_api_error(reason)
    end
  end
end
