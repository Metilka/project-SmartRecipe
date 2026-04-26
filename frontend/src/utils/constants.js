export const STORAGE_KEYS = {
  session: 'dietrix_session_v2',
};

export const SORT_OPTIONS = [
  { value: 'default', label: 'По умолчанию' },
  { value: 'title', label: 'По названию' },
  { value: 'kcal-asc', label: 'Меньше ккал' },
  { value: 'protein-desc', label: 'Больше белка' },
  { value: 'cooking-time-asc', label: 'Быстрее готовится' },
];

// Медицинские флаги. id совпадает с именем колонки в user_profiles (backend).
export const MEDICAL_FLAG_OPTIONS = [
  {
    id: 'low_sodium',
    label: 'Низкий натрий',
    helper: 'Более строгий порог натрия при фильтрации рецептов.',
  },
  {
    id: 'low_sugar',
    label: 'Низкий сахар',
    helper: 'Ужесточает порог сахара на 100 г.',
  },
  {
    id: 'low_fat',
    label: 'Низкий жир',
    helper: 'Снижает допустимую жирность для выдачи.',
  },
  {
    id: 'no_spicy',
    label: 'Без острого',
    helper: 'Исключает рецепты с острыми ингредиентами.',
  },
  {
    id: 'no_acidic',
    label: 'Без кислого',
    helper: 'Исключает продукты с выраженной кислотностью.',
  },
  {
    id: 'no_saturated_fat',
    label: 'Без насыщенных жиров',
    helper: 'Исключает ингредиенты с высоким содержанием насыщенных жиров.',
  },
];

// Дневные цели. id совпадает с именем колонки в user_profiles.
export const TARGET_FIELD_OPTIONS = [
  { id: 'target_kcal', label: 'Ккал / сутки', min: 1000, max: 4000, step: 50 },
  { id: 'target_protein', label: 'Белки / сутки, г', min: 40, max: 220, step: 5 },
  { id: 'target_fat', label: 'Жиры / сутки, г', min: 20, max: 160, step: 5 },
  { id: 'target_carbs', label: 'Углеводы / сутки, г', min: 40, max: 350, step: 5 },
  { id: 'target_sugar', label: 'Сахар / сутки, г', min: 0, max: 120, step: 1 },
  { id: 'target_sodium_mg', label: 'Натрий / сутки, мг', min: 300, max: 4000, step: 50 },
];

// Методы приготовления — ключи соответствуют значениям recipes.cooking_method в БД (на русском).
export const COOKING_METHOD_LABELS = {
  варка: 'Варка',
  'на пару': 'На пару',
  тушение: 'Тушение',
  запекание: 'Запекание',
  жарка: 'Жарка',
  'без обработки': 'Без обработки',
};

export const COOKING_METHOD_OPTIONS = Object.entries(COOKING_METHOD_LABELS).map(
  ([value, label]) => ({ value, label })
);
