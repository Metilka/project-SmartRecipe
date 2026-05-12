import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import NutrientTable from '../components/NutrientTable';
import RecipeBreakdown from '../components/RecipeBreakdown';
import ScoreBadge from '../components/ScoreBadge';
import SectionCard from '../components/SectionCard';
import { basketApi, recipesApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { formatCookingTime, formatMethodLabel } from '../utils/helpers';

export default function PersonalRecipePage() {
  const navigate = useNavigate();
  const { recipeId } = useParams();
  const { currentDiet, actions } = useDietrixStore();
  const { pushToast } = actions;
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [servings, setServings] = useState(1);
  const [adding, setAdding] = useState(false);

  const loadRecipe = useCallback(async () => {
    try {
      setLoading(true);
      setError('');
      const response = await recipesApi.getPersonal(recipeId);
      setData(response);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось получить персональную карточку.');
    } finally {
      setLoading(false);
    }
  }, [recipeId]);

  useEffect(() => {
    loadRecipe();
  }, [loadRecipe]);

  if (loading) {
    return <Loader fullScreen label="Оцениваем рецепт по вашему профилю…" />;
  }

  if (error || !data) {
    return (
      <ErrorState
        message={error || 'Данные по рецепту не найдены.'}
        onRetry={loadRecipe}
      />
    );
  }

  if (data.blocked) {
    const reasons = data.reasons || data.block_reasons || [];
    return (
      <ErrorState
        title="Рецепт исключён фильтрацией"
        message={reasons.length ? reasons.join(' · ') : 'Не подходит под текущие ограничения.'}
        onRetry={() => navigate('/recommendations')}
      />
    );
  }

  const recipe = data.recipe || {};
  const nutrients = recipe.nutrients_per_100g || {};
  const finalScore = typeof data.final_score === 'number'
    ? Math.round(data.final_score)
    : 0;
  const reasons = Array.isArray(data.fit_reasons) ? data.fit_reasons : [];
  const penalties = Array.isArray(data.penalties) ? data.penalties : [];

  const instructionSteps = String(recipe.instructions || '')
    .split(/\s*\d+\.\s+|\n+/)
    .map((step) => step.trim())
    .filter(Boolean);

  const handleAddToBasket = async () => {
    try {
      setAdding(true);
      await basketApi.add({ recipeId: recipe.id, servings });
      pushToast({
        type: 'success',
        title: 'Добавлено в план',
        message: `${recipe.title} — ${servings} ${servings === 1 ? 'порция' : 'порций'}.`,
      });
    } catch (e) {
      pushToast({
        type: 'error',
        title: 'Не удалось добавить',
        message: e.message || 'Попробуйте ещё раз.',
      });
    } finally {
      setAdding(false);
    }
  };

  return (
    <div className="page-stack">
      <SectionCard
        title="Персональная страница рецепта"
        subtitle="Подробная карточка с оценкой соответствия вашему профилю."
        actions={
          <div className="recipe-page-actions">
            <button
              className="aero-button secondary"
              type="button"
              onClick={() => navigate(-1)}
            >
              Назад
            </button>
            <div className="servings-control">
              <label>
                Порций:
                <input
                  className="aero-input aero-input--narrow"
                  type="number"
                  min="0.5"
                  max="20"
                  step="0.5"
                  value={servings}
                  onChange={(e) =>
                    setServings(Math.max(0.5, Number(e.target.value) || 1))
                  }
                />
              </label>
            </div>
            <button
              className="aero-button primary"
              type="button"
              onClick={handleAddToBasket}
              disabled={adding}
            >
              {adding ? 'Добавляем…' : '+ В план'}
            </button>
          </div>
        }
      >
        <div className="recipe-hero recipe-hero--personal">
          <div>
            <h1>{recipe.title}</h1>
            {data.explain && <p>{data.explain}</p>}
            <div className="recipe-hero__meta">
              <span className="status-chip">
                {formatMethodLabel(recipe.cooking_method)}
              </span>
              {recipe.cooking_time != null && (
                <span className="status-chip subtle">
                  {formatCookingTime(recipe.cooking_time)}
                </span>
              )}
              {recipe.servings != null && (
                <span className="status-chip subtle">
                  Порций: {recipe.servings}
                </span>
              )}
            </div>
          </div>
          <div className="recipe-score-box glass-inset">
            <ScoreBadge score={finalScore} />
            {currentDiet && (
              <small>
                №{currentDiet.id} · {currentDiet.name}
              </small>
            )}
          </div>
        </div>
      </SectionCard>

      <RecipeBreakdown
        breakdown={data.breakdown || {}}
        reasons={reasons}
        penalties={penalties}
      />

      <SectionCard
        title="Нутриенты на 100 г"
        subtitle="Сравниваются с целевыми показателями вашего профиля."
      >
        <NutrientTable nutrients={nutrients} />
      </SectionCard>

      <div className="detail-columns detail-columns--stacked">
        <SectionCard title="Ингредиенты">
          {recipe.ingredients?.length ? (
            <ul className="plain-list">
              {recipe.ingredients.map((ingredient, idx) => (
                <li key={`${ingredient.product_id || 'custom'}-${idx}`}>
                  <strong>{ingredient.ingredient_name}</strong>
                  {ingredient.quantity != null && (
                    <>
                      {' '}
                      — {ingredient.quantity}
                      {ingredient.unit ? ` ${ingredient.unit}` : ''}
                    </>
                  )}
                </li>
              ))}
            </ul>
          ) : (
            <p>Состав не указан.</p>
          )}
        </SectionCard>

        <SectionCard
          title="Шаги приготовления"
          subtitle={formatMethodLabel(recipe.cooking_method)}
        >
          {instructionSteps.length ? (
            <ol className="plain-list plain-list--ordered">
              {instructionSteps.map((step, idx) => (
                <li key={idx}>{step}</li>
              ))}
            </ol>
          ) : (
            <p>{recipe.instructions || 'Инструкция отсутствует.'}</p>
          )}
        </SectionCard>
      </div>
    </div>
  );
}
