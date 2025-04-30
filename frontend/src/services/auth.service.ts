import axios from 'axios';
import { AuthResponse, LoginCredentials, RegisterCredentials } from '../types/auth.types';

const API_URL = '/api';

// Сервис для работы с аутентификацией через Elixir API
export const AuthService = {
  // Метод для входа пользователя
  login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const response = await axios.post<AuthResponse>(`${API_URL}/auth/login`, credentials);
    if (response.data.token) {
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
    }
    return response.data;
  },

  // Метод для регистрации нового пользователя
  register: async (credentials: RegisterCredentials): Promise<AuthResponse> => {
    const response = await axios.post<AuthResponse>(`${API_URL}/auth/register`, {
      user: {
        username: credentials.username,
        email: credentials.email,
        password: credentials.password
      }
    });
    
    if (response.data.token) {
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
    }
    return response.data;
  },

  // Метод для выхода пользователя
  logout: (): void => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  // Метод для получения текущего пользователя
  getCurrentUser: () => {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
  },

  // Метод для проверки, авторизован ли пользователь
  isAuthenticated: (): boolean => {
    return !!localStorage.getItem('token');
  },

  // Метод для получения токена авторизации
  getToken: (): string | null => {
    return localStorage.getItem('token');
  },

  // Получение информации о пользователе с сервера
  getUserInfo: async (): Promise<any> => {
    const token = AuthService.getToken();
    if (!token) {
      return null;
    }

    try {
      const response = await axios.get(`${API_URL}/user`, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      return response.data;
    } catch (error) {
      console.error('Ошибка получения информации о пользователе:', error);
      return null;
    }
  }
};

// Настройка перехватчика запросов для добавления токена
axios.interceptors.request.use(
  (config) => {
    const token = AuthService.getToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
); 