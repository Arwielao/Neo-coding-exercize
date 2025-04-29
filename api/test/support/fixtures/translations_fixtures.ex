defmodule Api.TranslationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Translations` context.
  """

  @doc """
  Generate a translation.
  """
  def translation_fixture(attrs \\ %{}) do
    {:ok, translation} =
      attrs
      |> Enum.into(%{
        from_lang: "some from_lang",
        poetic_version: "some poetic_version",
        text: "some text",
        to_lang: "some to_lang",
        translated_text: "some translated_text"
      })
      |> Api.Translations.create_translation()

    translation
  end
end
