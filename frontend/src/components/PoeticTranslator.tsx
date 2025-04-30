import React, { useState } from 'react';
import { TranslationService } from '../services/translation.service';
import { TranslationResponse } from '../types/translation.types';
import { useAuth } from '../context/AuthContext';
import 'bootstrap/dist/css/bootstrap.min.css';

// Компонент для поэтического перевода
const PoeticTranslator: React.FC = () => {
  const { authState } = useAuth();
  const [text, setText] = useState('');
  const [fromLang, setFromLang] = useState('ru');
  const [toLang, setToLang] = useState('en');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<TranslationResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Список поддерживаемых языков
  const languages = [
    { code: 'ru', name: 'Russian' },
    { code: 'en', name: 'English' },
    { code: 'fr', name: 'French' },
    { code: 'de', name: 'German' },
    { code: 'es', name: 'Spanish' },
    { code: 'it', name: 'Italian' },
  ];

  // Обработчик отправки формы
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!text.trim()) {
      setError('Please enter text to translate');
      return;
    }
    
    setLoading(true);
    setError(null);
    
    try {
      const response = await TranslationService.getPoeticTranslation({
        text,
        from_lang: fromLang,
        to_lang: toLang
      });
      
      setResult(response);
    } catch (error) {
      console.error('Ошибка перевода:', error);
      setError('An error occurred during translation. Please try again later.');
    } finally {
      setLoading(false);
    }
  };

  // Форматирование поэтического текста для отображения
  const formatPoem = (poem: string) => {
    return poem.split('\n').map((line, index) => (
      <React.Fragment key={index}>
        {line}
        <br />
      </React.Fragment>
    ));
  };

  return (
    <div className="container mt-4">
      <div className="row mb-4">
        <div className="col">
          <h2 className="text-center">Poetic Translator</h2>
          <p className="text-center text-muted">
            Convert your text into beautiful poetry and translate it to another language
          </p>
        </div>
      </div>

      {authState.user && (
        <div className="row mb-4">
          <div className="col">
            <div className="welcome-box">
              Welcome, {authState.user.username}!
            </div>
          </div>
        </div>
      )}

      <div className="row">
        <div className="col-md-6 mb-4">
          <div className="card h-100">
            <div className="card-header">
              <h4>Text to Translate</h4>
            </div>
            <div className="card-body">
              {error && (
                <div className="alert alert-danger" role="alert">
                  {error}
                </div>
              )}
              <form onSubmit={handleSubmit}>
                <div className="mb-3">
                  <textarea
                    className="form-control"
                    rows={5}
                    value={text}
                    onChange={(e) => setText(e.target.value)}
                    placeholder="Enter text to translate..."
                    required
                  />
                </div>
                
                <div className="row mb-3">
                  <div className="col-md-6">
                    <label htmlFor="fromLang" className="form-label">
                      Source Language
                    </label>
                    <select
                      id="fromLang"
                      className="form-select"
                      value={fromLang}
                      onChange={(e) => setFromLang(e.target.value)}
                    >
                      {languages.map((lang) => (
                        <option key={lang.code} value={lang.code}>
                          {lang.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div className="col-md-6">
                    <label htmlFor="toLang" className="form-label">
                      Target Language
                    </label>
                    <select
                      id="toLang"
                      className="form-select"
                      value={toLang}
                      onChange={(e) => setToLang(e.target.value)}
                    >
                      {languages.map((lang) => (
                        <option key={lang.code} value={lang.code}>
                          {lang.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                
                <div className="d-grid">
                  <button
                    type="submit"
                    className="btn btn-primary"
                    disabled={loading}
                  >
                    {loading ? (
                      <>
                        <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                        Translating...
                      </>
                    ) : (
                      'Translate and Poeticize'
                    )}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
        
        <div className="col-md-6 mb-4">
          <div className="card h-100">
            <div className="card-header">
              <h4>Translation Result</h4>
            </div>
            <div className="card-body">
              {result ? (
                <div>
                  <div className="mb-4">
                    <h5>Original Text:</h5>
                    <p>{result.original_text}</p>
                  </div>
                  
                  <div className="mb-4">
                    <h5>Poetic Representation:</h5>
                    <div className="p-3 poem-box rounded">
                      {formatPoem(result.source_poem)}
                    </div>
                  </div>
                  
                  <div className="mb-4">
                    <h5>Translated Text:</h5>
                    <p>{result.translated_text}</p>
                  </div>
                  
                  <div>
                    <h5>Poetic Translation:</h5>
                    <div className="p-3 poem-box rounded">
                      {formatPoem(result.target_poem)}
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center text-muted p-5">
                  <i className="bi bi-translate fs-1"></i>
                  <p className="mt-3">
                    Your poetic translation will appear here
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PoeticTranslator; 