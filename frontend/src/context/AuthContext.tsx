import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import { AuthService } from '../services/auth.service';
import { AuthState, LoginCredentials, RegisterCredentials, User } from '../types/auth.types';

// Начальное состояние аутентификации
const initialState: AuthState = {
  isAuthenticated: false,
  user: null,
  loading: true,
  error: null
};

// Интерфейс для контекста аутентификации
interface AuthContextProps {
  authState: AuthState;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (credentials: RegisterCredentials) => Promise<void>;
  logout: () => void;
  clearError: () => void;
}

// Создание контекста
const AuthContext = createContext<AuthContextProps | undefined>(undefined);

// Поставщик контекста аутентификации
export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [authState, setAuthState] = useState<AuthState>(initialState);

  // Проверка наличия пользователя при загрузке
  useEffect(() => {
    const checkAuthStatus = () => {
      const isAuthenticated = AuthService.isAuthenticated();
      const user = AuthService.getCurrentUser();
      
      setAuthState({
        isAuthenticated,
        user,
        loading: false,
        error: null
      });
    };
    
    checkAuthStatus();
  }, []);

  // Очистка ошибок
  const clearError = () => {
    setAuthState(prevState => ({
      ...prevState,
      error: null
    }));
  };

  // Функция для входа пользователя
  const login = async (credentials: LoginCredentials) => {
    try {
      setAuthState({ ...authState, loading: true, error: null });
      const response = await AuthService.login(credentials);
      
      setAuthState({
        isAuthenticated: true,
        user: response.user,
        loading: false,
        error: null
      });
    } catch (error) {
      setAuthState({
        ...authState,
        loading: false,
        error: 'Ошибка входа. Проверьте учетные данные.'
      });
      throw error;
    }
  };

  // Функция для регистрации пользователя
  const register = async (credentials: RegisterCredentials) => {
    try {
      setAuthState({ ...authState, loading: true, error: null });
      const response = await AuthService.register(credentials);
      
      setAuthState({
        isAuthenticated: true,
        user: response.user,
        loading: false,
        error: null
      });
    } catch (error) {
      setAuthState({
        ...authState,
        loading: false,
        error: 'Ошибка регистрации. Попробуйте другие данные.'
      });
      throw error;
    }
  };

  // Функция для выхода пользователя
  const logout = () => {
    AuthService.logout();
    setAuthState({
      isAuthenticated: false,
      user: null,
      loading: false,
      error: null
    });
  };

  return (
    <AuthContext.Provider value={{ authState, login, register, logout, clearError }}>
      {children}
    </AuthContext.Provider>
  );
};

// Хук для использования контекста аутентификации
export const useAuth = (): AuthContextProps => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}; 