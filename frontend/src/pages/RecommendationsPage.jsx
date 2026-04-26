import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import EmptyState from '../components/EmptyState';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import RecommendationCard from '../components/RecommendationCard';
import SectionCard from '../components/SectionCard';
import { recommendationsApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { COOKING_METHOD_LABELS } from '../utils/constants';

const defaultFilters = {
  query: '',
  minScore: 0,
  method: 'all',
};

export default function RecommendationsPage() {
  const navigate = useNavigate();
  const { currentDiet, profile } = useDietrixStore();
  const [filters, setFilters] = useState(defaultFilters);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadRecommendations = useCallback(async () => {
    try {
      setLoading(true);
      setError('');
      const response = await recommendationsApi.list({ limit: 30 });
      // Бэкенд возвращает { user_id, diet_id, count, recipes: [...] }.
      // Каждый item — это плоский объект с title, cooking_method,
      // nutrients_per_100g, final_score, breakdown, fit_reasons и т. д.
      const raw = Array.isArray(response)
        ? response
        : response.recipes || response.items || [];
      setItems(raw);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось получить персональную выдачу.');
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (currentDiet) {
      loadRecommendations();
    } else {
      setLoading(false);
    }
  }, [currentDiet, profile, loadRecommendations]);

  const filteredItems = useMemo(() => {
    const q = filters.query.trim().toLowerCase();
    return items.filter((item) => {
      const score = typeof item.final_score === 'number' ? item.final_score : 0;
      if (score < filters.minScore) return false;
      if (filters.method !== 'all' && item.cooking_method !== filters.method) {
        return false;
      }
      if (q) {
        const hay = `${item.title || ''} ${item.description || ''}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }, [items, filters.query, filters.minScore, filters.method]);

  const stats = useMemo(() => {
    if (!filteredItems.length) return { count: 0, averageScore: 0 };
    const avg =
      filteredItems.reduce(
        (sum, item) => sum + (item.final_score || 0),
        0
      ) / filteredItems.length;
    return { count: filteredItems.length, averageScore: Math.round(avg) };
  }, [filteredItems]);

  if (loading && !items.length) {
    return <Loader fullScreen label="Формируем персональную выдачу…" />;
  }

  if (!currentDiet) {
    return (
      <EmptyState
        title="Диета не выбрана"
        message="Зайдите в профиль и выберите диету, чтобы получать персональные рекомендации."
        actionLabel="В профиль"
        onAction={() => navigate('/profile')}
      />
    );
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Рекомендации"
        subtitle="Персональная подборка рецептов, отсортированная по степени соответствия вашему профилю."
      >
        <div className="toolbar glass-inset toolbar--multi-line">
          <div className="toolbar__group">
            <div className="toolbar-pill">№{currentDiet.id}</div>
            <div className="toolbar-copy">
              <strong>{stats.count} рецептов в выдаче</strong>
              <span>Средняя оценка: {stats.averageScore}</span>
            </div>
          </div>

          <div className="toolbar__group toolbar__group--stretch">
            <label className="field-group field-group--inline">
              <span>Поиск</span>
              <input
                className="aero-input"
                type="search"
                value={filters.query}
                onChange={(event) =>
                  setFilters((c) => ({ ...c, query: event.target.value }))
                }
                placeholder="Название или описание"
              />
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Мин. оценка</span>
              <input
                className="aero-input"
                type="number"
                min="0"
                max="100"
                value={filters.minScore}
                onChange={(event) =>
                  setFilters((c) => ({
                    ...c,
                    minScore: Number(event.target.value) || 0,
                  }))
                }
              />
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Метод</span>
              <select
                className="aero-select"
                value={filters.method}
                onChange={(event) =>
                  setFilters((c) => ({ ...c, method: event.target.value }))
                }
              >
                <option value="all">Все методы</option>
                {Object.entries(COOKING_METHOD_LABELS).map(([value, label]) => (
                  <option key={value} value={value}>
                    {label}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </div>
      </SectionCard>

      {loading && items.length > 0 && (
        <Loader label="Обновляем карточки под новые фильтры…" />
      )}
      {!loading && error && <ErrorState message={error} onRetry={loadRecommendations} />}

      {!loading && !error && filteredItems.length === 0 && (
        <EmptyState
          message={
            items.length === 0
              ? 'По текущим ограничениям рецептов не найдено. Попробуйте ослабить медицинские флаги или уменьшить список исключённых продуктов.'
              : 'По текущим фильтрам ничего не нашлось. Попробуйте снизить минимальную оценку или сменить метод приготовления.'
          }
          actionLabel="Изменить профиль"
          onAction={() => navigate('/profile')}
        />
      )}

      {!error && filteredItems.length > 0 && (
        <div className="card-list">
          {filteredItems.map((item) => (
            <RecommendationCard
              key={item.recipe_id}
              item={item}
              onOpen={(recipeId) => navigate(`/recipes/${recipeId}/personal`)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
