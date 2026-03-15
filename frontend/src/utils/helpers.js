import { dietLookup } from '../data/diets';
import { productLookup } from '../data/products';
import { COOKING_METHOD_LABELS } from './constants';

export const clamp = (value, min = 0, max = 1) => Math.min(Math.max(value, min), max);

export const round = (value, digits = 1) => Number(value.toFixed(digits));

export const uid = (prefix = 'id') => `${prefix}-${Math.random().toString(36).slice(2, 10)}`;

export const slugify = (value) =>
  value
    .toLowerCase()
    .replace(/[^a-zа-я0-9]+/gi, '-')
    .replace(/^-+|-+$/g, '');

export const deepClone = (value) => JSON.parse(JSON.stringify(value));

export const formatDietLabel = (dietId) => {
  const diet = dietLookup[dietId];
  return diet ? `${diet.id} · ${diet.name}` : dietId;
};

export const formatMethodLabel = (method) => COOKING_METHOD_LABELS[method] || method;

export const formatNutrientValue = (key, value) => {
  const unit = key === 'kcal' ? 'ккал' : key === 'sodium' ? 'мг' : 'г';
  return `${round(value, key === 'sodium' ? 0 : 1)} ${unit}`;
};

export const getProductName = (productId) => productLookup[productId]?.name || productId;

export const sleep = (ms = 500) => new Promise((resolve) => setTimeout(resolve, ms));

export const hasPreferenceTag = (recipe, preferenceId) => recipe.preferenceTags?.includes(preferenceId);

export const createExplainSentence = ({ ingredientScore, nutrientScore, cookingMethodScore, personalScore }) => {
  const chunks = [];

  if (ingredientScore >= 0.86) {
    chunks.push('сильное соответствие составу диеты');
  }
  if (nutrientScore >= 0.8) {
    chunks.push('ровные нутриенты на 100 г');
  }
  if (cookingMethodScore >= 0.95) {
    chunks.push('подходящий метод приготовления');
  }
  if (personalScore >= 0.7) {
    chunks.push('совпадение с персональными предпочтениями');
  }

  if (!chunks.length) {
    return 'Рецепт прошёл фильтрацию и остаётся допустимым вариантом, но без ярко выраженного персонального преимущества.';
  }

  return `Высокая позиция за ${chunks.join(', ')}.`;
};

export const sortRecipes = (recipes, sortBy) => {
  const list = [...recipes];

  switch (sortBy) {
    case 'title':
      return list.sort((a, b) => a.title.localeCompare(b.title, 'ru'));
    case 'kcal-asc':
      return list.sort((a, b) => a.nutrientsPer100g.kcal - b.nutrientsPer100g.kcal);
    case 'protein-desc':
      return list.sort((a, b) => b.nutrientsPer100g.protein - a.nutrientsPer100g.protein);
    default:
      return list;
  }
};
