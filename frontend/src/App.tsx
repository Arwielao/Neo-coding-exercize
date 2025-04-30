import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Login from './components/auth/Login';
import Register from './components/auth/Register';
import PoeticTranslator from './components/PoeticTranslator';
import ProtectedRoute from './components/auth/ProtectedRoute';
import Navbar from './components/Navbar';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';

// Главный компонент приложения
function App() {
  return (
    <AuthProvider>
      <Router>
    <div className="App">
          <Navbar />
          <div className="content">
            <Routes>
              {/* Публичные маршруты */}
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              
              {/* Защищенные маршруты */}
              <Route element={<ProtectedRoute />}>
                <Route path="/dashboard" element={<PoeticTranslator />} />
              </Route>
              
              {/* Перенаправление на дашборд или логин в зависимости от авторизации */}
              <Route path="/" element={<Navigate to="/dashboard" replace />} />
              <Route path="*" element={<Navigate to="/dashboard" replace />} />
            </Routes>
          </div>
    </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
