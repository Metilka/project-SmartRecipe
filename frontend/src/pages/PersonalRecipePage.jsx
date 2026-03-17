import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import NutrientTable from '../components/NutrientTable';
import RecipeBreakdown from '../components/RecipeBreakdown';
import ScoreBadge from '../components/ScoreBadge';
import SectionCard from '../components/SectionCard';
import { mockApi } from '../data/mockApi';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function PersonalRecipePage() {
  const navigate = useNavigate();
  const { recipeId } = useParams();
  const { currentDiet, profile } = useDietrixStore();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadRecipe = async () => {
    try {
      setLoading(true);
      setError('');
      const response = await mockApi.getPersonalRecipe({
        recipeId,
        dietId: currentDiet.id,
        profile,
      });
      setData(response);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось получить детальную персональную карточку.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (currentDiet) {
      loadRecipe();
    }
  }, [recipeId, currentDiet, profile]);

  if (loading) {
    return <Loader fullScreen label="Оцениваем рецепт по персональным правилам…" />;
  }

  if (error || !data) {
    return <ErrorState message={error || 'Данные по рецепту не найдены.'} onRetry={loadRecipe} />;
  }

  if (data.blocked) {
    return (
      <ErrorState
        title="Рецепт исключён фильтрацией"
        message={data.reasons.join(' ')}
        onRetry={() => navigate('/recommendations')}
      />
    );
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Персональная страница рецепта"
        subtitle="Подробная карточка с оценкой соответствия вашему профилю."
        actions={
          <button className="aero-button secondary" type="button" onClick={() => navigate(-1)}>
            Назад
          </button>
        }
      >
        <div className="recipe-hero recipe-hero--personal">
          <div>
            <span className="recipe-card__category">{data.recipe.category}</span>
            <h1>{data.recipe.title}</h1>
            <p>{data.explain}</p>
          </div>
          <div className="recipe-score-box glass-inset">
            <ScoreBadge score={data.finalScore} />
            <small>{currentDiet.id} · {currentDiet.name}</small>
          </div>
        </div>
      </SectionCard>

      <RecipeBreakdown breakdown={data.breakdown} reasons={data.reasons} penalties={data.penalties} />

      <div className="detail-columns">
        <SectionCard title="Нутриенты на 100 г" subtitle="Сравниваются с целевыми показателями вашего профиля.">
          <NutrientTable nutrients={data.recipe.nutrientsPer100g} />
        </SectionCard>

        <SectionCard title="Почему этот рецепт вам подходит" subtitle="Основные причины высокой позиции в выдаче.">
          <ul className="plain-list">
            {data.reasons.map((reason) => (
              <li key={reason}>{reason}</li>
            ))}
          </ul>
        </SectionCard>
      </div>

      <div className="detail-columns detail-columns--stacked">
        <SectionCard title="Ингредиенты">
          <ul className="plain-list">
            {data.recipe.ingredients.map((ingredient) => (
              <li key={`${ingredient.productId}-${ingredient.amount}`}>
                <strong>{ingredient.name}</strong> — {ingredient.amount}
              </li>
            ))}
          </ul>
        </SectionCard>

        <SectionCard title="Шаги приготовления" subtitle={data.recipe.cookingMethodLabel}>
          <ol className="plain-list plain-list--ordered">
            {data.recipe.steps.map((step) => (
              <li key={step}>{step}</li>
            ))}
          </ol>
        </SectionCard>
      </div>
    </div>
  );
}
