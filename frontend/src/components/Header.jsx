import { NavLink, useNavigate } from 'react-router-dom';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { formatDietLabel } from '../utils/helpers';

const guestLinks = [
  { to: '/guest/diets', label: 'Диеты' },
  { to: '/guest/feed', label: 'Лента' },
];

const authLinks = [
  { to: '/profile', label: 'Профиль' },
  { to: '/recommendations', label: 'Рекомендации' },
];

export default function Header() {
  const navigate = useNavigate();
  const { isAuthenticated, authUser, currentDiet, session, actions } = useDietrixStore();

  const handleLogout = () => {
    actions.logout();
    actions.pushToast({
      type: 'info',
      title: 'Сессия завершена',
      message: 'Вы вернулись в гостевой режим.',
    });
    navigate('/guest/diets');
  };

  return (
    <header className="app-header glass-panel">
      <div className="header-brand" onClick={() => navigate(isAuthenticated ? '/recommendations' : '/guest/diets')}>
        <div className="header-brand__orb" />
        <div>
          <strong>Dietrix</strong>
          <span>Подбор рецептов по диетам</span>
        </div>
      </div>

      <nav className="header-nav" aria-label="Главная навигация">
        {guestLinks.map((link) => (
          <NavLink
            key={link.to}
            to={link.to}
            className={({ isActive }) => `nav-pill ${isActive ? 'is-active' : ''}`.trim()}
          >
            {link.label}
          </NavLink>
        ))}

        {isAuthenticated &&
          authLinks.map((link) => (
            <NavLink
              key={link.to}
              to={link.to}
              className={({ isActive }) => `nav-pill ${isActive ? 'is-active' : ''}`.trim()}
            >
              {link.label}
            </NavLink>
          ))}
      </nav>

      <div className="header-actions">
        {currentDiet && <div className="status-chip">{formatDietLabel(currentDiet.id)}</div>}

        <button
          className={`mode-button ${session.mode === 'guest' ? 'is-active' : ''}`.trim()}
          type="button"
          onClick={() => navigate('/guest/diets')}
        >
          Гость
        </button>

        <button
          className={`mode-button ${session.mode === 'auth' ? 'is-active' : ''}`.trim()}
          type="button"
          onClick={() => navigate(isAuthenticated ? '/recommendations' : '/auth')}
        >
          Персонально
        </button>

        {isAuthenticated ? (
          <>
            <div className="header-user">
              <span>{authUser?.email}</span>
            </div>
            <button className="aero-button" type="button" onClick={handleLogout}>
              Выйти
            </button>
          </>
        ) : (
          <button className="aero-button primary" type="button" onClick={() => navigate('/auth')}>
            Вход / регистрация
          </button>
        )}
      </div>
    </header>
  );
}
