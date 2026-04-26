const LABELS = {
  ingredient_score: 'Состав',
  nutrient_score: 'Нутриенты',
  cooking_method_score: 'Способ приготовления',
  personal_score: 'Персональные предпочтения',
};

export default function RecipeBreakdown({ breakdown = {}, reasons = [], penalties = [] }) {
  const entries = Object.entries(breakdown).filter(
    ([key]) => LABELS[key]
  );

  return (
    <div className="recipe-breakdown">
      <div className="recipe-breakdown__scores glass-panel">
        <h3>Детализация оценки</h3>
        {entries.length === 0 && <p>Нет данных по детализации.</p>}
        {entries.map(([key, value]) => {
          const num = typeof value === 'number' ? value : 0;
          const percent = Math.min(100, Math.max(0, num * 100));
          return (
            <div key={key} className="breakdown-row">
              <div className="breakdown-row__header">
                <span>{LABELS[key]}</span>
                <strong>{num.toFixed(2)}</strong>
              </div>
              <div className="rating-meter rating-meter--compact" aria-hidden="true">
                <span style={{ width: `${percent}%` }} />
              </div>
            </div>
          );
        })}
      </div>

      <div className="recipe-breakdown__lists">
        <div className="glass-panel breakdown-list-panel">
          <h4>Почему рецепт вам подходит</h4>
          {reasons.length ? (
            <ul className="plain-list">
              {reasons.map((reason) => (
                <li key={reason}>{reason}</li>
              ))}
            </ul>
          ) : (
            <p>Нет дополнительных причин.</p>
          )}
        </div>

        <div className="glass-panel breakdown-list-panel">
          <h4>Причины штрафов / ограничений</h4>
          {penalties.length ? (
            <ul className="plain-list">
              {penalties.map((penalty) => (
                <li key={penalty}>{penalty}</li>
              ))}
            </ul>
          ) : (
            <p>Существенных штрафов не найдено.</p>
          )}
        </div>
      </div>
    </div>
  );
}
