defmodule ApiWeb.TranslationControllerTest do
  use ApiWeb.ConnCase

  import Api.TranslationsFixtures

  alias Api.Translations.Translation

  @create_attrs %{
    text: "some text",
    translated_text: "some translated_text",
    poetic_version: "some poetic_version",
    from_lang: "some from_lang",
    to_lang: "some to_lang"
  }
  @update_attrs %{
    text: "some updated text",
    translated_text: "some updated translated_text",
    poetic_version: "some updated poetic_version",
    from_lang: "some updated from_lang",
    to_lang: "some updated to_lang"
  }
  @invalid_attrs %{text: nil, translated_text: nil, poetic_version: nil, from_lang: nil, to_lang: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all translations", %{conn: conn} do
      conn = get(conn, ~p"/api/translations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create translation" do
    test "renders translation when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/translations", translation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/translations/#{id}")

      assert %{
               "id" => ^id,
               "from_lang" => "some from_lang",
               "poetic_version" => "some poetic_version",
               "text" => "some text",
               "to_lang" => "some to_lang",
               "translated_text" => "some translated_text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/translations", translation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update translation" do
    setup [:create_translation]

    test "renders translation when data is valid", %{conn: conn, translation: %Translation{id: id} = translation} do
      conn = put(conn, ~p"/api/translations/#{translation}", translation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/translations/#{id}")

      assert %{
               "id" => ^id,
               "from_lang" => "some updated from_lang",
               "poetic_version" => "some updated poetic_version",
               "text" => "some updated text",
               "to_lang" => "some updated to_lang",
               "translated_text" => "some updated translated_text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, translation: translation} do
      conn = put(conn, ~p"/api/translations/#{translation}", translation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete translation" do
    setup [:create_translation]

    test "deletes chosen translation", %{conn: conn, translation: translation} do
      conn = delete(conn, ~p"/api/translations/#{translation}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/translations/#{translation}")
      end
    end
  end

  defp create_translation(_) do
    translation = translation_fixture()
    %{translation: translation}
  end
end
