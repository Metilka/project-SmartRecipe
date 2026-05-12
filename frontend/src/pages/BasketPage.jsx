import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import EmptyState from '../components/EmptyState';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import SectionCard from '../components/SectionCard';
import { basketApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { formatNutrientValue } from '../utils/helpers';

const TOTAL_KEYS = ['kcal', 'protein', 'fat', 'carbs', 'sugar', 'sodium_mg'];
const TOTAL_LABELS = {
  kcal: 'Ккал',
  protein: 'Белки',
  fat: 'Жиры',
  carbs: 'Углеводы',
  sugar: 'Сахар',
  sodium_mg: 'Натрий',
};

export default function BasketPage() {
  const navigate = useNavigate();
  const { actions } = useDietrixStore();
  const [data, setData] = useState({ entries: [], totals: {}, warnings: [] });
  const [loading, setLoading] = useState(true);
  const [clearing, setClearing] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    try {
      setLoading(true);
      setError('');
      const response = await basketApi.get();
      setData({
        entries: response.entries || [],
        totals: response.totals || {},
        warnings: response.warnings || [],
      });
    } catch (loadError) {
      setError(loadError.message || 'Не удалось загрузить корзину.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const handleClear = async () => {
    if (!data.entries.length) return;
    try {
      setClearing(true);
      await basketApi.clear();
      await load();
      actions.pushToast({
        type: 'success',
        title: 'Корзина очищена',
        message: 'Дневной план обнулён.',
      });
    } catch (e) {
      actions.pushToast({
        type: 'error',
        title: 'Не удалось очистить',
        message: e.message || 'Попробуйте ещё раз.',
      });
    } finally {
      setClearing(false);
    }
  };

  if (loading) {
    return <Loader fullScreen label="Загружаем дневной план…" />;
  }

  if (error) {
    return <ErrorState message={error} onRetry={load} />;
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Дневной план"
        subtitle="Корзина рецептов на сегодня. Суммирует нутриенты и сравнивает с вашими целями и нормами диеты."
        actions={
          data.entries.length > 0 && (
            <button
              className="aero-button"
              type="button"
              onClick={handleClear}
              disabled={clearing}
            >
              {clearing ? 'Очищаем…' : 'Очистить план'}
            </button>
          )
        }
      >
        <div className="basket-totals">
          {TOTAL_KEYS.map((key) => (
            <div key={key} className="basket-total-chip">
              <span>{TOTAL_LABELS[key]}</span>
              <strong>{formatNutrientValue(key, data.totals[key])}</strong>
            </div>
          ))}
        </div>
      </SectionCard>

      {data.warnings.length > 0 && (
        <SectionCard title="Предупреждения">
          <ul className="plain-list plain-list--warnings">
            {data.warnings.map((warning, idx) => (
              <li key={idx}>⚠ {warning}</li>
            ))}
          </ul>
        </SectionCard>
      )}

      {data.entries.length === 0 ? (
        <EmptyState
          title="План пуст"
          message="Откройте карточку любого рецепта и нажмите «Добавить в план», чтобы посчитать нутриенты на день."
          actionLabel="К рекомендациям"
          onAction={() => navigate('/recommendations')}
        />
      ) : (
        <SectionCard title={`Добавлено рецептов: ${data.entries.length}`}>
          <ul className="basket-list">
            {data.entries.map((entry, idx) => (
              <li key={`${entry.recipe_id}-${idx}`} className="basket-list__item">
                <div>
                  <strong>{entry.title}</strong>
                  <span className="basket-list__servings">
                    Порций: {entry.servings}
                  </span>
                </div>
                <div className="basket-list__nutrients">
                  {TOTAL_KEYS.map((key) => (
                    <span key={key}>
                      {TOTAL_LABELS[key]}:{' '}
                      <strong>{formatNutrientValue(key, entry[key])}</strong>
                    </span>
                  ))}
                </div>
              </li>
            ))}
          </ul>
        </SectionCard>
      )}
    </div>
  );
}
