import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import EmptyState from '../components/EmptyState';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import RecommendationCard from '../components/RecommendationCard';
import SectionCard from '../components/SectionCard';
import { mockApi } from '../data/mockApi';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { COOKING_METHOD_LABELS, RECOMMENDATION_FILTERS } from '../utils/constants';

const defaultFilters = {
  query: '',
  minScore: 55,
  method: 'all',
  restriction: 'all',
};

export default function RecommendationsPage() {
  const navigate = useNavigate();
  const { currentDiet, profile } = useDietrixStore();
  const [filters, setFilters] = useState(defaultFilters);
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadRecommendations = async () => {
    try {
      setLoading(true);
      setError('');
      const response = await mockApi.getRecommendations({
        dietId: currentDiet.id,
        profile,
        filters,
      });
      setItems(response);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось получить персональную выдачу.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (currentDiet) {
      loadRecommendations();
    }
  }, [currentDiet, profile, filters.query, filters.minScore, filters.method, filters.restriction]);

  const stats = useMemo(() => {
    if (!items.length) {
      return { count: 0, averageScore: 0 };
    }

    const averageScore = Math.round(items.reduce((sum, item) => sum + item.finalScore, 0) / items.length);
    return { count: items.length, averageScore };
  }, [items]);

  if (loading && !items.length) {
    return <Loader fullScreen label="Формируем персональную выдачу…" />;
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Рекомендации"
        subtitle="Персональная подборка рецептов, отсортированная по степени соответствия вашему профилю."
      >
        <div className="toolbar glass-inset toolbar--multi-line">
          <div className="toolbar__group">
            <div className="toolbar-pill">{currentDiet.id}</div>
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
                onChange={(event) => setFilters((current) => ({ ...current, query: event.target.value }))}
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
                onChange={(event) => setFilters((current) => ({ ...current, minScore: Number(event.target.value) }))}
              />
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Метод</span>
              <select
                className="aero-select"
                value={filters.method}
                onChange={(event) => setFilters((current) => ({ ...current, method: event.target.value }))}
              >
                <option value="all">Все методы</option>
                {Object.entries(COOKING_METHOD_LABELS).map(([value, label]) => (
                  <option key={value} value={value}>
                    {label}
                  </option>
                ))}
              </select>
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Ограничения</span>
              <select
                className="aero-select"
                value={filters.restriction}
                onChange={(event) => setFilters((current) => ({ ...current, restriction: event.target.value }))}
              >
                {RECOMMENDATION_FILTERS.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </div>
      </SectionCard>

      {loading && items.length > 0 && <Loader label="Обновляем карточки под новые фильтры…" />}
      {!loading && error && <ErrorState message={error} onRetry={loadRecommendations} />}

      {!loading && !error && !items.length && (
        <EmptyState
          message="Ограничения стали слишком строгими. Попробуйте уменьшить список исключённых продуктов, скорректировать дневные цели или фильтры."
          actionLabel="Изменить профиль"
          onAction={() => navigate('/profile')}
        />
      )}

      {!error && items.length > 0 && (
        <div className="card-list">
          {items.map((item) => (
            <RecommendationCard key={item.recipe.id} item={item} onOpen={(recipeId) => navigate(`/recipes/${recipeId}/personal`)} />
          ))}
        </div>
      )}
    </div>
  );
}
