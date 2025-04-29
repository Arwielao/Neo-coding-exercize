defmodule Api.Translations.Translation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field :text, :string
    field :translated_text, :string
    field :poetic_version, :string
    field :from_lang, :string
    field :to_lang, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:text, :translated_text, :poetic_version, :from_lang, :to_lang])
    |> validate_required([:text, :translated_text, :poetic_version, :from_lang, :to_lang])
  end
end
