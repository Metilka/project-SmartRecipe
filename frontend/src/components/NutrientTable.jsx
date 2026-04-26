import { formatNutrientValue } from '../utils/helpers';

const labels = {
  kcal: 'Ккал',
  protein: 'Белки',
  fat: 'Жиры',
  carbs: 'Углеводы',
  sugar: 'Сахар',
  sodium_mg: 'Натрий',
};

export default function NutrientTable({ nutrients, compact = false }) {
  const keys = ['kcal', 'protein', 'fat', 'carbs', 'sugar', 'sodium_mg'];
  const safeNutrients = nutrients || {};

  if (compact) {
    return (
      <div className="nutrient-grid nutrient-grid--compact">
        {keys.map((key) => (
          <div key={key} className="nutrient-chip">
            <span>{labels[key]}</span>
            <strong>{formatNutrientValue(key, safeNutrients[key])}</strong>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="nutrient-table" role="table" aria-label="Нутриенты на 100 грамм">
      {keys.map((key) => (
        <div key={key} className="nutrient-row" role="row">
          <span className="nutrient-row__label" role="cell">
            {labels[key]}
          </span>
          <strong className="nutrient-row__value" role="cell">
            {formatNutrientValue(key, safeNutrients[key])}
          </strong>
        </div>
      ))}
    </div>
  );
}
