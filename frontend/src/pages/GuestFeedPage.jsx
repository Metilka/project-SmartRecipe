import { useCallback, useEffect, useRef, useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import EmptyState from '../components/EmptyState';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import RecipeCard from '../components/RecipeCard';
import SectionCard from '../components/SectionCard';
import { recipesApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import {
  COOKING_METHOD_OPTIONS,
  SORT_OPTIONS,
} from '../utils/constants';
import { sortRecipes } from '../utils/helpers';

export default function GuestFeedPage() {
  const navigate = useNavigate();
  const { currentDiet } = useDietrixStore();
  const [recipes, setRecipes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filters, setFilters] = useState({
    query: '',
    sortBy: 'default',
    cookingMethod: 'all',
  });

  // Debounce для поиска — чтобы не дёргать бэк на каждый символ
  const debounceRef = useRef(null);
  const [debouncedQuery, setDebouncedQuery] = useState('');

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      setDebouncedQuery(filters.query.trim());
    }, 350);
    return () => clearTimeout(debounceRef.current);
  }, [filters.query]);

  const loadRecipes = useCallback(async () => {
    if (!currentDiet) return;

    try {
      setLoading(true);
      setError('');
      const response = await recipesApi.list({
        dietId: currentDiet.id,
        search: debouncedQuery || undefined,
        cookingMethod:
          filters.cookingMethod !== 'all' ? filters.cookingMethod : undefined,
        perPage: 50,
      });
      setRecipes(response.recipes || []);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось загрузить ленту.');
      setRecipes([]);
    } finally {
      setLoading(false);
    }
  }, [currentDiet, debouncedQuery, filters.cookingMethod]);

  useEffect(() => {
    loadRecipes();
  }, [loadRecipes]);

  const sorted = sortRecipes(recipes, filters.sortBy);

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
            <div className="toolbar-pill">№{currentDiet.id}</div>
            <div className="toolbar-copy">
              <strong>{currentDiet.name}</strong>
              <span>{currentDiet.description}</span>
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
                  setFilters((current) => ({ ...current, query: event.target.value }))
                }
                placeholder="Название или описание"
              />
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Метод</span>
              <select
                className="aero-select"
                value={filters.cookingMethod}
                onChange={(event) =>
                  setFilters((current) => ({
                    ...current,
                    cookingMethod: event.target.value,
                  }))
                }
              >
                <option value="all">Все методы</option>
                {COOKING_METHOD_OPTIONS.map((opt) => (
                  <option key={opt.value} value={opt.value}>
                    {opt.label}
                  </option>
                ))}
              </select>
            </label>

            <label className="field-group field-group--inline field-group--narrow">
              <span>Сортировка</span>
              <select
                className="aero-select"
                value={filters.sortBy}
                onChange={(event) =>
                  setFilters((current) => ({
                    ...current,
                    sortBy: event.target.value,
                  }))
                }
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

      {!loading && !error && sorted.length === 0 && (
        <EmptyState
          message="По текущим фильтрам рецептов не нашлось. Попробуйте очистить поиск или выбрать другой метод приготовления."
          actionLabel="Сменить диету"
          onAction={() => navigate('/guest/diets')}
        />
      )}

      {!loading && !error && sorted.length > 0 && (
        <div className="card-list">
          {sorted.map((recipe) => (
            <RecipeCard
              key={recipe.id}
              recipe={recipe}
              onOpen={(recipeId) => navigate(`/guest/recipes/${recipeId}`)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
