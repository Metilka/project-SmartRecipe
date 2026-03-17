import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import NutrientTable from '../components/NutrientTable';
import SectionCard from '../components/SectionCard';
import { mockApi } from '../data/mockApi';
import { useDietrixStore } from '../hooks/useDietrixStore';

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
      const response = await mockApi.fetchRecipe(recipeId);
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
            <span className="recipe-card__category">{recipe.category}</span>
            <h1>{recipe.title}</h1>
            <p>{recipe.description}</p>
          </div>
          <div className="recipe-diet-note glass-inset">
            <span>Относится к диете</span>
            <strong>{recipe.dietId}</strong>
            <small>{currentDiet?.name || recipe.heroNote}</small>
          </div>
        </div>
      </SectionCard>

      <div className="detail-columns">
        <SectionCard title="Нутриенты на 100 г" subtitle="Показатели для гостевого просмотра без персонального пересчёта.">
          <NutrientTable nutrients={recipe.nutrientsPer100g} />
        </SectionCard>

        <SectionCard title="Метод приготовления" subtitle={recipe.cookingMethodLabel}>
          <p>{recipe.preparationSummary}</p>
        </SectionCard>
      </div>

      <div className="detail-columns detail-columns--stacked">
        <SectionCard title="Ингредиенты">
          <ul className="plain-list">
            {recipe.ingredients.map((ingredient) => (
              <li key={`${ingredient.productId}-${ingredient.amount}`}>
                <strong>{ingredient.name}</strong> — {ingredient.amount}
              </li>
            ))}
          </ul>
        </SectionCard>

        <SectionCard title="Способ приготовления">
          <ol className="plain-list plain-list--ordered">
            {recipe.steps.map((step) => (
              <li key={step}>{step}</li>
            ))}
          </ol>
        </SectionCard>
      </div>
    </div>
  );
}
