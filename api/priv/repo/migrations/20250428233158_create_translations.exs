defmodule Api.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :text, :string
      add :translated_text, :string
      add :poetic_version, :text
      add :from_lang, :string
      add :to_lang, :string

      timestamps(type: :utc_datetime)
    end
  end
end
