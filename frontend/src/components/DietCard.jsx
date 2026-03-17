export default function DietCard({ diet, selected, onSelect }) {
  return (
    <article className={`diet-card glass-panel ${selected ? 'is-selected' : ''}`.trim()}>
      <div className="diet-card__top">
        <div>
          <span className="diet-card__code">{diet.id}</span>
          <h3>{diet.name}</h3>
        </div>
        <div className="status-chip subtle">{diet.allowedProducts.length} продуктов</div>
      </div>

      <p className="diet-card__description">{diet.shortDescription}</p>

      <div className="diet-card__restrictions">
        {diet.restrictions.map((restriction) => (
          <span key={restriction} className="soft-chip">
            {restriction}
          </span>
        ))}
      </div>

      <button className="aero-button primary diet-card__button" type="button" onClick={() => onSelect(diet.id)}>
        Выбрать
      </button>
    </article>
  );
}
