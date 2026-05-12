import { useState } from 'react';
import { basketApi } from '../api';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { formatMethodLabel, formatNutrientValue } from '../utils/helpers';
import ScoreBadge from './ScoreBadge';

export default function RecommendationCard({ item, onOpen }) {
  const { actions } = useDietrixStore();
  const [adding, setAdding] = useState(false);

  // Бэкенд кладёт поля рецепта прямо в item: title, description, cooking_method,
  // nutrients_per_100g, final_score, breakdown, fit_reasons, penalties, explain
  const nutrients = item.nutrients_per_100g || {};
  const reasons = Array.isArray(item.fit_reasons) ? item.fit_reasons : [];
  const score =
    typeof item.final_score === 'number' ? Math.round(item.final_score) : 0;

  const handleAddToBasket = async (event) => {
    event.stopPropagation();
    try {
      setAdding(true);
      await basketApi.add({ recipeId: item.recipe_id, servings: 1 });
      actions.pushToast({
        type: 'success',
        title: 'Добавлено в план',
        message: `${item.title} — 1 порция.`,
      });
    } catch (e) {
      actions.pushToast({
        type: 'error',
        title: 'Не удалось добавить',
        message: e.message || 'Попробуйте ещё раз.',
      });
    } finally {
      setAdding(false);
    }
  };

  return (
    <article className="recommendation-card glass-panel">
      <div className="recommendation-card__top">
        <div>
          <h3>{item.title}</h3>
          {item.description && (
            <p className="recommendation-card__description">{item.description}</p>
          )}
        </div>
        <ScoreBadge score={score} />
      </div>

      {item.explain && (
        <p className="recommendation-card__explain">{item.explain}</p>
      )}

      <div className="rating-meter" aria-hidden="true">
        <span style={{ width: `${Math.min(score, 100)}%` }} />
      </div>

      <div className="recommendation-card__meta">
        <div>
          <span>Метод</span>
          <strong>{formatMethodLabel(item.cooking_method)}</strong>
        </div>
        <div>
          <span>Сахар</span>
          <strong>{formatNutrientValue('sugar', nutrients.sugar)}</strong>
        </div>
        <div>
          <span>Натрий</span>
          <strong>{formatNutrientValue('sodium_mg', nutrients.sodium_mg)}</strong>
        </div>
      </div>

      {reasons.length > 0 && (
        <div className="recommendation-card__reasons">
          {reasons.slice(0, 4).map((reason) => (
            <span key={reason} className="soft-chip">
              {reason}
            </span>
          ))}
        </div>
      )}

      <div className="recommendation-card__actions">
        <button
          className="aero-button primary"
          type="button"
          onClick={() => onOpen(item.recipe_id)}
        >
          Открыть
        </button>
        <button
          className="aero-button secondary"
          type="button"
          onClick={handleAddToBasket}
          disabled={adding}
        >
          {adding ? 'Добавляем…' : '+ В план'}
        </button>
      </div>
    </article>
  );
}
