import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import ProfileForm from '../components/ProfileForm';
import SectionCard from '../components/SectionCard';
import { profileApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { profileFromApi, profileToApi } from '../utils/helpers';

export default function ProfilePage() {
  const navigate = useNavigate();
  const { authUser, diets, currentDiet, profile, actions } = useDietrixStore();

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [dietChanging, setDietChanging] = useState(false);
  const [error, setError] = useState('');

  const reload = async () => {
    try {
      setLoading(true);
      setError('');
      await actions.refreshProfile();
    } catch (e) {
      setError(e.message || 'Не удалось загрузить профиль.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    reload();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleSave = async (nextProfile) => {
    try {
      setSaving(true);
      setError('');
      const payload = profileToApi(nextProfile);
      const response = await profileApi.update(payload);
      const merged = {
        selected_diet_id: response.selected_diet_id,
        excluded_product_ids: response.excluded_product_ids || [],
        favorite_product_ids: response.favorite_product_ids || [],
        allowed_products: profile.allowed_products,
        profile: response.profile,
      };
      actions.setProfileLocal(profileFromApi(merged));
      actions.pushToast({
        type: 'success',
        title: 'Профиль сохранён',
        message: 'Изменения учтены в персональной выдаче.',
      });
    } catch (e) {
      actions.pushToast({
        type: 'error',
        title: 'Ошибка сохранения',
        message: e.message || 'Не удалось сохранить профиль.',
      });
    } finally {
      setSaving(false);
    }
  };

  const handleReset = async () => {
    try {
      await actions.refreshProfile();
      actions.pushToast({
        type: 'info',
        title: 'Изменения отменены',
        message: 'Загружены актуальные данные с сервера.',
      });
    } catch (e) {
      /* ignore */
    }
  };

  const handleChangeDiet = async (nextDietId) => {
    if (!nextDietId || nextDietId === profile.selected_diet_id) return;
    try {
      setDietChanging(true);
      await profileApi.selectDiet(nextDietId);
      await actions.refreshProfile();
      actions.pushToast({
        type: 'success',
        title: 'Диета изменена',
        message: 'Список разрешённых продуктов обновлён.',
      });
    } catch (e) {
      actions.pushToast({
        type: 'error',
        title: 'Не удалось сменить диету',
        message: e.message || 'Попробуйте ещё раз.',
      });
    } finally {
      setDietChanging(false);
    }
  };

  const handleRefreshRecommendations = async (nextProfile) => {
    await handleSave(nextProfile);
    navigate('/recommendations');
  };

  if (loading) {
    return <Loader fullScreen label="Загружаем профиль…" />;
  }

  if (error) {
    return <ErrorState message={error} onRetry={reload} />;
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Профиль пользователя"
        subtitle="Настройте исключения, ограничения и цели по нутриентам."
      >
        <div className="hero-banner">
          <div>
            <h3>{authUser?.email}</h3>
            <p>
              Текущая диета — <strong>№{currentDiet?.id || '—'}</strong>
              {currentDiet?.name ? ` (${currentDiet.name})` : ''}. Изменения профиля
              влияют на фильтрацию рецептов, целевые показатели и порядок выдачи.
            </p>
          </div>
          <div className="status-chip">
            Разрешённых продуктов: {profile.allowed_products?.length || 0}
          </div>
        </div>
      </SectionCard>

      {currentDiet ? (
        <ProfileForm
          diets={diets}
          currentDietId={profile.selected_diet_id}
          allowedProducts={profile.allowed_products}
          profile={profile}
          onSave={handleSave}
          onReset={handleReset}
          onChangeDiet={handleChangeDiet}
          onRefreshRecommendations={handleRefreshRecommendations}
          saving={saving}
          dietChanging={dietChanging}
        />
      ) : (
        <SectionCard title="Выберите диету">
          <p>У вашего аккаунта пока не выбрана диета. Выберите её ниже:</p>
          <div className="form-action-row">
            {diets.map((d) => (
              <button
                key={d.id}
                className="aero-button primary"
                type="button"
                onClick={() => handleChangeDiet(d.id)}
              >
                №{d.id} — {d.name}
              </button>
            ))}
          </div>
        </SectionCard>
      )}
    </div>
  );
}
