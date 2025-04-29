defmodule Api.TranslationsTest do
  use Api.DataCase

  alias Api.Translations

  describe "translations" do
    alias Api.Translations.Translation

    import Api.TranslationsFixtures

    @invalid_attrs %{text: nil, translated_text: nil, poetic_version: nil, from_lang: nil, to_lang: nil}

    test "list_translations/0 returns all translations" do
      translation = translation_fixture()
      assert Translations.list_translations() == [translation]
    end

    test "get_translation!/1 returns the translation with given id" do
      translation = translation_fixture()
      assert Translations.get_translation!(translation.id) == translation
    end

    test "create_translation/1 with valid data creates a translation" do
      valid_attrs = %{text: "some text", translated_text: "some translated_text", poetic_version: "some poetic_version", from_lang: "some from_lang", to_lang: "some to_lang"}

      assert {:ok, %Translation{} = translation} = Translations.create_translation(valid_attrs)
      assert translation.text == "some text"
      assert translation.translated_text == "some translated_text"
      assert translation.poetic_version == "some poetic_version"
      assert translation.from_lang == "some from_lang"
      assert translation.to_lang == "some to_lang"
    end

    test "create_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_translation(@invalid_attrs)
    end

    test "update_translation/2 with valid data updates the translation" do
      translation = translation_fixture()
      update_attrs = %{text: "some updated text", translated_text: "some updated translated_text", poetic_version: "some updated poetic_version", from_lang: "some updated from_lang", to_lang: "some updated to_lang"}

      assert {:ok, %Translation{} = translation} = Translations.update_translation(translation, update_attrs)
      assert translation.text == "some updated text"
      assert translation.translated_text == "some updated translated_text"
      assert translation.poetic_version == "some updated poetic_version"
      assert translation.from_lang == "some updated from_lang"
      assert translation.to_lang == "some updated to_lang"
    end

    test "update_translation/2 with invalid data returns error changeset" do
      translation = translation_fixture()
      assert {:error, %Ecto.Changeset{}} = Translations.update_translation(translation, @invalid_attrs)
      assert translation == Translations.get_translation!(translation.id)
    end

    test "delete_translation/1 deletes the translation" do
      translation = translation_fixture()
      assert {:ok, %Translation{}} = Translations.delete_translation(translation)
      assert_raise Ecto.NoResultsError, fn -> Translations.get_translation!(translation.id) end
    end

    test "change_translation/1 returns a translation changeset" do
      translation = translation_fixture()
      assert %Ecto.Changeset{} = Translations.change_translation(translation)
    end
  end
end
