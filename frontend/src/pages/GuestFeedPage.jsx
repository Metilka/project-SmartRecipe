import { useEffect, useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import EmptyState from '../components/EmptyState';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import RecipeCard from '../components/RecipeCard';
import SectionCard from '../components/SectionCard';
import { mockApi } from '../data/mockApi';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { SORT_OPTIONS } from '../utils/constants';

export default function GuestFeedPage() {
  const navigate = useNavigate();
  const { currentDiet } = useDietrixStore();
  const [recipes, setRecipes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filters, setFilters] = useState({ query: '', sortBy: 'relevance' });

  const loadRecipes = async () => {
    if (!currentDiet) return;

    try {
      setLoading(true);
      setError('');
      const response = await mockApi.fetchGuestFeed({
        dietId: currentDiet.id,
        query: filters.query,
        sortBy: filters.sortBy,
      });
      setRecipes(response);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось загрузить ленту.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRecipes();
  }, [currentDiet, filters.query, filters.sortBy]);

  if (!currentDiet) {
    return <Navigate to="/guest/diets" replace />;
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Лента рецептов"
        subtitle="Рецепты по выбранной диете. Используйте поиск и сортировку для удобной навигации."
      >
        <div className="toolbar glass-inset">
          <div className="toolbar__group">
            <div className="toolbar-pill">{currentDiet.id}</div>
            <div className="toolbar-copy">
              <strong>{currentDiet.name}</strong>
              <span>{currentDiet.shortDescription}</span>
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
                placeholder="Название, описание или способ приготовления"
              />
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Сортировка</span>
              <select
                className="aero-select"
                value={filters.sortBy}
                onChange={(event) => setFilters((current) => ({ ...current, sortBy: event.target.value }))}
              >
                {SORT_OPTIONS.map((option) => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </div>
      </SectionCard>

      {loading && <Loader label="Подгружаем ленту рецептов…" />}

      {!loading && error && <ErrorState message={error} onRetry={loadRecipes} />}

      {!loading && !error && !recipes.length && (
        <EmptyState
          message="Похоже, текущий запрос слишком узкий. Попробуйте очистить поиск или сменить диету."
          actionLabel="Сменить диету"
          onAction={() => navigate('/guest/diets')}
        />
      )}

      {!loading && !error && recipes.length > 0 && (
        <div className="card-list">
          {recipes.map((recipe) => (
            <RecipeCard key={recipe.id} recipe={recipe} onOpen={(recipeId) => navigate(`/guest/recipes/${recipeId}`)} />
          ))}
        </div>
      )}
    </div>
  );
}
