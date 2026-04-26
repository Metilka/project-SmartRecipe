import { COOKING_METHOD_LABELS } from './constants';

export const uid = (prefix = 'id') =>
  `${prefix}-${Math.random().toString(36).slice(2, 10)}`;

export const deepClone = (value) => JSON.parse(JSON.stringify(value));

export const formatMethodLabel = (method) =>
  COOKING_METHOD_LABELS[method] || method || '—';

export const formatNutrientValue = (key, value) => {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return '—';
  }
  const unit = key === 'kcal' ? 'ккал' : key === 'sodium_mg' ? 'мг' : 'г';
  const num = Number(value);
  const rounded =
    key === 'sodium_mg' ? Math.round(num) : Math.round(num * 10) / 10;
  return `${rounded} ${unit}`;
};

// Сортировка по полям, которые реально приходят из API (/recipes, /feed).
// nutrients_per_100g: { kcal, protein, fat, carbs, sugar, sodium_mg }
export const sortRecipes = (recipes, sortBy) => {
  const list = [...recipes];
  switch (sortBy) {
    case 'title':
      return list.sort((a, b) =>
        (a.title || '').localeCompare(b.title || '', 'ru')
      );
    case 'kcal-asc':
      return list.sort(
        (a, b) =>
          (a.nutrients_per_100g?.kcal ?? Infinity) -
          (b.nutrients_per_100g?.kcal ?? Infinity)
      );
    case 'protein-desc':
      return list.sort(
        (a, b) =>
          (b.nutrients_per_100g?.protein ?? -Infinity) -
          (a.nutrients_per_100g?.protein ?? -Infinity)
      );
    case 'cooking-time-asc':
      return list.sort(
        (a, b) =>
          (a.cooking_time ?? Infinity) - (b.cooking_time ?? Infinity)
      );
    default:
      return list;
  }
};

// Пустой профиль в новом формате, соответствующем user_profiles в БД.
export const createEmptyProfile = () => ({
  selected_diet_id: null,
  excluded_product_ids: [],
  favorite_product_ids: [],
  allowed_products: [],
  flags: {
    low_sodium: false,
    low_sugar: false,
    low_fat: false,
    no_spicy: false,
    no_acidic: false,
    no_saturated_fat: false,
  },
  targets: {
    target_kcal: '',
    target_protein: '',
    target_fat: '',
    target_carbs: '',
    target_sugar: '',
    target_sodium_mg: '',
  },
});

// Превращает ответ GET /profile в формат, удобный для UI.
export const profileFromApi = (apiPayload) => {
  const base = createEmptyProfile();
  if (!apiPayload) return base;

  const p = apiPayload.profile || {};

  return {
    selected_diet_id: apiPayload.selected_diet_id ?? null,
    excluded_product_ids: apiPayload.excluded_product_ids || [],
    favorite_product_ids: apiPayload.favorite_product_ids || [],
    allowed_products: apiPayload.allowed_products || [],
    flags: {
      low_sodium: !!p.low_sodium,
      low_sugar: !!p.low_sugar,
      low_fat: !!p.low_fat,
      no_spicy: !!p.no_spicy,
      no_acidic: !!p.no_acidic,
      no_saturated_fat: !!p.no_saturated_fat,
    },
    targets: {
      target_kcal: p.target_kcal ?? '',
      target_protein: p.target_protein ?? '',
      target_fat: p.target_fat ?? '',
      target_carbs: p.target_carbs ?? '',
      target_sugar: p.target_sugar ?? '',
      target_sodium_mg: p.target_sodium_mg ?? '',
    },
  };
};

// Превращает UI-форму профиля в payload для PUT /profile.
export const profileToApi = (uiProfile) => {
  const payload = {};
  if (uiProfile.selected_diet_id) {
    payload.selected_diet_id = uiProfile.selected_diet_id;
  }
  payload.excluded_product_ids = [...uiProfile.excluded_product_ids];
  payload.favorite_product_ids = [...uiProfile.favorite_product_ids];

  // Флаги: всегда отправляем все 6
  Object.entries(uiProfile.flags).forEach(([k, v]) => {
    payload[k] = !!v;
  });

  // Дневные цели: пустая строка → null, иначе число
  Object.entries(uiProfile.targets).forEach(([k, v]) => {
    if (v === '' || v === null || v === undefined) {
      payload[k] = null;
    } else {
      const num = Number(v);
      payload[k] = Number.isNaN(num) ? null : num;
    }
  });

  // Фронтенд больше не использует preference_tags — отправляем пустой массив,
  // чтобы сбросить возможные старые значения на сервере.
  payload.preference_tags = [];

  return payload;
};

export const isEmptyArray = (arr) => !Array.isArray(arr) || arr.length === 0;

export const formatCookingTime = (minutes) => {
  if (minutes === null || minutes === undefined) return '—';
  if (minutes < 60) return `${minutes} мин`;
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m ? `${h} ч ${m} мин` : `${h} ч`;
};
