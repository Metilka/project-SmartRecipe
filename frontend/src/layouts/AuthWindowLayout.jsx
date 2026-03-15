import { Outlet } from 'react-router-dom';

export default function AuthWindowLayout() {
  return (
    <div className="auth-layout">
      <div className="auth-layout__backdrop" />
      <div className="auth-layout__content">
        <div className="auth-layout__intro glass-panel">
          <span className="sidebar-widget__eyebrow">Dietrix</span>
          <h1>Персонализация рекомендаций</h1>
          <p>
            После входа вы сможете настроить исключения продуктов, медицинские ограничения,
            дневные цели по нутриентам и персональные предпочтения — всё это влияет
            на фильтрацию и итоговую оценку рецептов.
          </p>
          <p className="auth-layout__note">
            Рекомендации справочные и не заменяют медицинскую консультацию.
          </p>
        </div>
        <Outlet />
      </div>
    </div>
  );
}
