import { formatCookingTime, formatMethodLabel } from '../utils/helpers';
import NutrientTable from './NutrientTable';

export default function RecipeCard({ recipe, onOpen }) {
  return (
    <article className="recipe-card glass-panel">
      <div className="recipe-card__header">
        <div>
          <h3>{recipe.title}</h3>
          <div className="recipe-card__meta-row">
            <span className="status-chip">{formatMethodLabel(recipe.cooking_method)}</span>
            {recipe.cooking_time != null && (
              <span className="status-chip subtle">
                {formatCookingTime(recipe.cooking_time)}
              </span>
            )}
          </div>
        </div>
      </div>

      {recipe.description && (
        <p className="recipe-card__description">{recipe.description}</p>
      )}

      <NutrientTable nutrients={recipe.nutrients_per_100g} compact />

      <button
        className="aero-button secondary recipe-card__button"
        type="button"
        onClick={() => onOpen(recipe.id)}
      >
        Подробнее
      </button>
    </article>
  );
}
