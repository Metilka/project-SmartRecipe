import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import NutrientTable from '../components/NutrientTable';
import SectionCard from '../components/SectionCard';
import { recipesApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { formatCookingTime, formatMethodLabel } from '../utils/helpers';

export default function GuestRecipePage() {
  const navigate = useNavigate();
  const { recipeId } = useParams();
  const { currentDiet } = useDietrixStore();
  const [recipe, setRecipe] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadRecipe = async () => {
    try {
      setLoading(true);
      setError('');
      const response = await recipesApi.getById(recipeId);
      setRecipe(response);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось открыть карточку рецепта.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRecipe();
  }, [recipeId]);

  if (loading) {
    return <Loader fullScreen label="Открываем карточку рецепта…" />;
  }

  if (error || !recipe) {
    return <ErrorState message={error || 'Рецепт не найден.'} onRetry={loadRecipe} />;
  }

  // Разбиваем инструкцию: backend возвращает одно поле instructions.
  // Пробуем разбить по шагам вида "1. ... 2. ..." или "\n".
  const instructionSteps = String(recipe.instructions || '')
    .split(/\s*\d+\.\s+|\n+/)
    .map((step) => step.trim())
    .filter(Boolean);

  return (
    <div className="page-stack">
      <SectionCard
        title="Страница рецепта"
        subtitle="Состав, нутриенты на 100 г и пошаговая инструкция приготовления."
        actions={
          <button className="aero-button secondary" type="button" onClick={() => navigate(-1)}>
            Назад
          </button>
        }
      >
        <div className="recipe-hero">
          <div>
            <h1>{recipe.title}</h1>
            <p>{recipe.description}</p>
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
          {currentDiet && (
            <div className="recipe-diet-note glass-inset">
              <span>Выбранная диета</span>
              <strong>№{currentDiet.id}</strong>
              <small>{currentDiet.name}</small>
            </div>
          )}
        </div>
      </SectionCard>

      <div className="detail-columns">
        <SectionCard
          title="Нутриенты на 100 г"
          subtitle="Показатели для гостевого просмотра без персонального пересчёта."
        >
          <NutrientTable nutrients={recipe.nutrients_per_100g} />
        </SectionCard>

        <SectionCard title="Метод приготовления">
          <p>{formatMethodLabel(recipe.cooking_method)}</p>
        </SectionCard>
      </div>

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

        <SectionCard title="Способ приготовления">
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
