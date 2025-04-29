defmodule ApiWeb.TranslationJSON do
  alias Api.Translations.Translation

  @doc """
  Renders a list of translations.
  """
  def index(%{translations: translations}) do
    %{data: for(translation <- translations, do: data(translation))}
  end

  @doc """
  Renders a single translation.
  """
  def show(%{translation: translation}) do
    %{data: data(translation)}
  end

  defp data(%Translation{} = translation) do
    %{
      id: translation.id,
      text: translation.text,
      translated_text: translation.translated_text,
      poetic_version: translation.poetic_version,
      from_lang: translation.from_lang,
      to_lang: translation.to_lang
    }
  end
end
