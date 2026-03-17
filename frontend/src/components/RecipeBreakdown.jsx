const labels = {
  ingredientScore: 'Состав',
  nutrientScore: 'Нутриенты',
  cookingMethodScore: 'Способ приготовления',
  personalScore: 'Предпочтения',
};

export default function RecipeBreakdown({ breakdown, reasons = [], penalties = [] }) {
  return (
    <div className="recipe-breakdown">
      <div className="recipe-breakdown__scores glass-panel">
        <h3>Детализация оценки</h3>
        {Object.entries(breakdown).map(([key, value]) => (
          <div key={key} className="breakdown-row">
            <div className="breakdown-row__header">
              <span>{labels[key]}</span>
              <strong>{value}</strong>
            </div>
            <div className="rating-meter rating-meter--compact" aria-hidden="true">
              <span style={{ width: `${value * 100}%` }} />
            </div>
          </div>
        ))}
      </div>

      <div className="recipe-breakdown__lists">
        <div className="glass-panel breakdown-list-panel">
          <h4>Почему рецепт вам подходит</h4>
          <ul className="plain-list">
            {reasons.map((reason) => (
              <li key={reason}>{reason}</li>
            ))}
          </ul>
        </div>

        <div className="glass-panel breakdown-list-panel">
          <h4>Причины штрафов / ограничений</h4>
          <ul className="plain-list">
            {penalties.length ? penalties.map((penalty) => <li key={penalty}>{penalty}</li>) : <li>Существенных штрафов не найдено.</li>}
          </ul>
        </div>
      </div>
    </div>
  );
}
