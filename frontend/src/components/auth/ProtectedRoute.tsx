import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

// Компонент для защиты маршрутов, требующих аутентификации
const ProtectedRoute: React.FC = () => {
  const { authState } = useAuth();
  
  // Если идет загрузка, показываем индикатор загрузки
  if (authState.loading) {
    return <div className="container mt-5 text-center">Загрузка...</div>;
  }
  
  // Если пользователь не аутентифицирован, перенаправляем на страницу входа
  if (!authState.isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  // Если пользователь аутентифицирован, рендерим дочерние маршруты
  return <Outlet />;
};

export default ProtectedRoute; 