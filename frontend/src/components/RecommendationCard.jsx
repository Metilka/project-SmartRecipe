import ScoreBadge from './ScoreBadge';

export default function RecommendationCard({ item, onOpen }) {
  return (
    <article className="recommendation-card glass-panel">
      <div className="recommendation-card__top">
        <div>
          <span className="recipe-card__category">{item.recipe.category}</span>
          <h3>{item.recipe.title}</h3>
        </div>
        <ScoreBadge score={item.finalScore} />
      </div>

      <p className="recommendation-card__explain">{item.explain}</p>

      <div className="rating-meter" aria-hidden="true">
        <span style={{ width: `${Math.min(item.finalScore, 100)}%` }} />
      </div>

      <div className="recommendation-card__meta">
        <div>
          <span>Метод</span>
          <strong>{item.recipe.cookingMethodLabel}</strong>
        </div>
        <div>
          <span>Сахар</span>
          <strong>{item.recipe.nutrientsPer100g.sugar} г</strong>
        </div>
        <div>
          <span>Натрий</span>
          <strong>{item.recipe.nutrientsPer100g.sodium} мг</strong>
        </div>
      </div>

      <div className="recommendation-card__reasons">
        {item.reasons.map((reason) => (
          <span key={reason} className="soft-chip">
            {reason}
          </span>
        ))}
      </div>

      <button className="aero-button primary" type="button" onClick={() => onOpen(item.recipe.id)}>
        Открыть
      </button>
    </article>
  );
}
