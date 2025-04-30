import axios from 'axios';
import { TranslationRequest, TranslationResponse } from '../types/translation.types';

const API_URL = '/api';

// Сервис для работы с поэтическими переводами
export const TranslationService = {
  // Метод для получения поэтического перевода
  getPoeticTranslation: async (request: TranslationRequest): Promise<TranslationResponse> => {
    const response = await axios.post<TranslationResponse>(
      `${API_URL}/translate/poetic/router`,
      request
    );
    return response.data;
  }
}; 