export const STORAGE_KEYS = {
  session: 'dietrix_session_v1',
  users: 'dietrix_users_v1',
};

export const DEFAULT_TOP_N = 8;

export const SORT_OPTIONS = [
  { value: 'relevance', label: 'Сначала релевантные' },
  { value: 'title', label: 'По названию' },
  { value: 'kcal-asc', label: 'Меньше ккал' },
  { value: 'protein-desc', label: 'Больше белка' },
];

export const RECOMMENDATION_FILTERS = [
  { value: 'all', label: 'Все ограничения' },
  { value: 'low-sugar', label: 'Низкий сахар' },
  { value: 'low-sodium', label: 'Низкий натрий' },
  { value: 'gentle', label: 'Щадящий режим' },
];

export const MEDICAL_FLAG_OPTIONS = [
  {
    id: 'gentleDigestion',
    label: 'Щадящее пищеварение',
    helper: 'Убирает грубые и агрессивные сочетания, усиливает контроль метода приготовления.',
  },
  {
    id: 'strictLowSugar',
    label: 'Жёсткий контроль сахара',
    helper: 'Применяет более строгий порог по сахару при фильтрации рецептов.',
  },
  {
    id: 'strictLowSodium',
    label: 'Жёсткий контроль натрия',
    helper: 'Дополнительно ограничивает натрий в блюдах.',
  },
  {
    id: 'reducedFat',
    label: 'Сниженный жир',
    helper: 'Дополнительно снижает допустимый жир для персональной выдачи.',
  },
];

export const TARGET_FIELD_OPTIONS = [
  { id: 'kcal', label: 'Ккал / сутки', min: 1000, max: 4000, step: 50 },
  { id: 'protein', label: 'Белки / сутки, г', min: 40, max: 220, step: 5 },
  { id: 'fat', label: 'Жиры / сутки, г', min: 20, max: 160, step: 5 },
  { id: 'carbs', label: 'Углеводы / сутки, г', min: 40, max: 350, step: 5 },
  { id: 'sugar', label: 'Сахар / сутки, г', min: 0, max: 120, step: 1 },
  { id: 'sodium', label: 'Натрий / сутки, мг', min: 300, max: 4000, step: 50 },
];

export const PREFERENCE_OPTIONS = [
  { id: 'breakfast', label: 'Завтрак' },
  { id: 'quick', label: 'Быстрое приготовление' },
  { id: 'fish', label: 'Больше рыбы' },
  { id: 'poultry', label: 'Птица' },
  { id: 'vegetables', label: 'Овощные блюда' },
  { id: 'soup', label: 'Супы и крем-супы' },
  { id: 'oven', label: 'Люблю запекание' },
  { id: 'grain', label: 'Крупы и гарниры' },
  { id: 'light-dinner', label: 'Лёгкий ужин' },
];

export const COOKING_METHOD_LABELS = {
  steamed: 'На пару',
  boiled: 'Варка',
  stewed: 'Тушение',
  baked: 'Запекание',
  baked_soft: 'Мягкое запекание',
  grilled: 'Гриль',
  fried: 'Жарка',
};
