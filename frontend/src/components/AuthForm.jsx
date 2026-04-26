import { useMemo, useState } from 'react';
import Loader from './Loader';

const initialState = {
  email: '',
  password: '',
};

export default function AuthForm({ onLogin, onRegister }) {
  const [tab, setTab] = useState('login');
  const [formState, setFormState] = useState(initialState);
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState('');

  const helperText = useMemo(
    () =>
      tab === 'login'
        ? 'Введите email и пароль, указанные при регистрации.'
        : 'После регистрации потребуется подтвердить почту — на неё придёт письмо со ссылкой.',
    [tab]
  );

  const validate = () => {
    if (!/^\S+@\S+\.\S+$/.test(formState.email.trim())) {
      return 'Введите корректный email.';
    }
    if (formState.password.length < 8) {
      return 'Пароль должен содержать минимум 8 символов.';
    }
    return '';
  };

  const handleChange = (event) => {
    const { name, value } = event.target;
    setFormError('');
    setFormState((current) => ({ ...current, [name]: value }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const validationError = validate();
    if (validationError) {
      setFormError(validationError);
      return;
    }

    try {
      setSubmitting(true);
      const payload = {
        email: formState.email.trim(),
        password: formState.password,
      };
      if (tab === 'login') {
        await onLogin(payload);
      } else {
        await onRegister(payload);
      }
    } catch (error) {
      setFormError(error.message || 'Не удалось выполнить запрос.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="auth-window glass-panel">
      <div className="auth-window__titlebar">
        <span>Dietrix Account</span>
        <div className="window-controls">
          <i />
          <i />
          <i />
        </div>
      </div>

      <div className="auth-tabs">
        <button
          className={`auth-tab ${tab === 'login' ? 'is-active' : ''}`.trim()}
          type="button"
          onClick={() => {
            setTab('login');
            setFormError('');
          }}
        >
          Вход
        </button>
        <button
          className={`auth-tab ${tab === 'register' ? 'is-active' : ''}`.trim()}
          type="button"
          onClick={() => {
            setTab('register');
            setFormError('');
          }}
        >
          Регистрация
        </button>
      </div>

      <form className="auth-form" onSubmit={handleSubmit}>
        <label className="field-group">
          <span>Email</span>
          <input
            className="aero-input"
            type="email"
            name="email"
            value={formState.email}
            onChange={handleChange}
            placeholder="name@example.com"
            autoComplete="email"
          />
          <small>Используется как логин для режима персонализации.</small>
        </label>

        <label className="field-group">
          <span>Пароль</span>
          <input
            className="aero-input"
            type="password"
            name="password"
            value={formState.password}
            onChange={handleChange}
            placeholder="Минимум 8 символов"
            autoComplete={tab === 'login' ? 'current-password' : 'new-password'}
          />
          <small>Пароль хранится в зашифрованном виде (bcrypt).</small>
        </label>

        <div className="form-helper-text">{helperText}</div>

        {formError && <div className="form-alert form-alert--error">{formError}</div>}

        <button className="aero-button primary auth-submit" type="submit" disabled={submitting}>
          {submitting ? (
            <Loader inline label={tab === 'login' ? 'Входим…' : 'Создаём аккаунт…'} />
          ) : tab === 'login' ? (
            'Войти'
          ) : (
            'Зарегистрироваться'
          )}
        </button>
      </form>
    </div>
  );
}
