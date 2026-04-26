import { Link } from 'react-router-dom';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { MEDICAL_FLAG_OPTIONS } from '../utils/constants';

export default function SidebarPanel() {
  const { currentDiet, isAuthenticated, profile } = useDietrixStore();

  const activeFlags = Object.entries(profile.flags || {}).filter(([, v]) => v);
  const excludedCount = profile.excluded_product_ids?.length || 0;

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
              <strong>№{currentDiet.id}</strong>
            </div>
            {isAuthenticated && (
              <>
                <div>
                  <span>Исключений</span>
                  <strong>{excludedCount}</strong>
                </div>
                <div>
                  <span>Ограничений</span>
                  <strong>{activeFlags.length}</strong>
                </div>
              </>
            )}
          </div>
        )}
      </div>

      {isAuthenticated && activeFlags.length > 0 && (
        <div className="glass-panel sidebar-widget">
          <div className="sidebar-widget__eyebrow">Активные ограничения</div>
          <ul className="sidebar-list">
            {activeFlags.map(([flagId]) => {
              const opt = MEDICAL_FLAG_OPTIONS.find((o) => o.id === flagId);
              return <li key={flagId}>{opt?.label || flagId}</li>;
            })}
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
