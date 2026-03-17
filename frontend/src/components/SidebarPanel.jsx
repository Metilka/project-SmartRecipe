import { Link } from 'react-router-dom';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function SidebarPanel() {
  const { currentDiet, isAuthenticated, profile } = useDietrixStore();

  const activeFlags = Object.values(profile.medicalFlags || {}).filter(Boolean).length;

  return (
    <aside className="sidebar-panel">
      <div className="glass-panel sidebar-widget">
        <div className="sidebar-widget__eyebrow">Режим</div>
        <h3>{isAuthenticated ? 'Персонализированная выдача' : 'Гостевой просмотр'}</h3>
        <p>
          {isAuthenticated
            ? 'Ваш профиль учитывается при фильтрации и ранжировании рецептов.'
            : 'Вы видите ленту по выбранной диете без персональных ограничений.'}
        </p>
        {currentDiet && (
          <div className="sidebar-stat-list">
            <div>
              <span>Диета</span>
              <strong>{currentDiet.id}</strong>
            </div>
            <div>
              <span>Исключения</span>
              <strong>{profile.excludedProducts?.length || 0}</strong>
            </div>
            <div>
              <span>Ограничения</span>
              <strong>{activeFlags}</strong>
            </div>
          </div>
        )}
      </div>

      {currentDiet && (
        <div className="glass-panel sidebar-widget">
          <div className="sidebar-widget__eyebrow">Ключевые ограничения</div>
          <ul className="sidebar-list">
            {currentDiet.restrictions.slice(0, 4).map((restriction) => (
              <li key={restriction}>{restriction}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="glass-panel sidebar-widget">
        <div className="sidebar-widget__eyebrow">Важно</div>
        <p>
          Рекомендации носят справочный характер и не являются медицинской консультацией.
          Перед изменением рациона проконсультируйтесь с врачом.
        </p>
        {isAuthenticated ? (
          <Link className="aero-button secondary button-link" to="/profile">
            Изменить профиль
          </Link>
        ) : (
          <Link className="aero-button secondary button-link" to="/auth">
            Перейти к персонализации
          </Link>
        )}
      </div>
    </aside>
  );
}
