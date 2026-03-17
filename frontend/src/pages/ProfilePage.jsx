import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import ProfileForm from '../components/ProfileForm';
import SectionCard from '../components/SectionCard';
import { mockApi } from '../data/mockApi';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function ProfilePage() {
  const navigate = useNavigate();
  const { authUser, currentDiet, profile, actions } = useDietrixStore();
  const [saving, setSaving] = useState(false);

  const handleSave = async (nextProfile) => {
    setSaving(true);
    try {
      actions.saveProfile(nextProfile);
      await mockApi.saveProfile({ userId: authUser.id, profile: nextProfile });
      actions.pushToast({
        type: 'success',
        title: 'Профиль сохранён',
        message: 'Изменения учтены в персональной выдаче.',
      });
    } finally {
      setSaving(false);
    }
  };

  const handleReset = () => {
    actions.resetProfile();
    actions.pushToast({
      type: 'info',
      title: 'Профиль сброшен',
      message: 'Возвращены базовые параметры профиля.',
    });
  };

  const handleRefreshRecommendations = async (nextProfile) => {
    await handleSave(nextProfile);
    navigate('/recommendations');
  };

  return (
    <div className="page-stack">
      <SectionCard
        title="Профиль пользователя"
        subtitle="Настройте исключения, ограничения и цели по нутриентам."
      >
        <div className="hero-banner">
          <div>
            <h3>{authUser.email}</h3>
            <p>
              Текущая диета — <strong>{currentDiet?.id}</strong>. Изменения профиля влияют на
              фильтрацию рецептов, целевые показатели и порядок выдачи.
            </p>
          </div>
          <div className="status-chip">Разрешённых продуктов: {currentDiet?.allowedProducts.length || 0}</div>
        </div>
      </SectionCard>

      {currentDiet && (
        <ProfileForm
          diet={currentDiet}
          profile={profile}
          onSave={handleSave}
          onReset={handleReset}
          onRefreshRecommendations={handleRefreshRecommendations}
          saving={saving}
        />
      )}
    </div>
  );
}
