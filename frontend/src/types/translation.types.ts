export interface TranslationRequest {
  text: string;
  from_lang: string;
  to_lang: string;
}

export interface TranslationResponse {
  from_lang: string;
  to_lang: string;
  original_text: string;
  translated_text: string;
  source_poem: string;
  target_poem: string;
} 