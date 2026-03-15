import NutrientTable from './NutrientTable';

export default function RecipeCard({ recipe, onOpen }) {
  return (
    <article className="recipe-card glass-panel">
      <div className="recipe-card__header">
        <div>
          <span className="recipe-card__category">{recipe.category}</span>
          <h3>{recipe.title}</h3>
        </div>
        <span className="status-chip">{recipe.cookingMethodLabel}</span>
      </div>

      <p className="recipe-card__description">{recipe.description}</p>
      <p className="recipe-card__summary">{recipe.preparationSummary}</p>

      <NutrientTable nutrients={recipe.nutrientsPer100g} compact />

      <button className="aero-button secondary recipe-card__button" type="button" onClick={() => onOpen(recipe.id)}>
        Подробнее
      </button>
    </article>
  );
}
