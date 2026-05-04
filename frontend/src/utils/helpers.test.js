import { describe, expect, it } from 'vitest';
import {
  formatCookingTime,
  formatNutrientValue,
  profileFromApi,
  profileToApi,
  sortRecipes,
} from './helpers';

describe('formatNutrientValue', () => {
  it('returns a dash for empty values', () => {
    expect(formatNutrientValue('kcal', null)).toBe('—');
    expect(formatNutrientValue('fat', Number.NaN)).toBe('—');
  });

  it('uses correct units and rounding', () => {
    expect(formatNutrientValue('kcal', 123.44)).toBe('123.4 ккал');
    expect(formatNutrientValue('sodium_mg', 123.6)).toBe('124 мг');
    expect(formatNutrientValue('protein', 7.26)).toBe('7.3 г');
  });
});

describe('formatCookingTime', () => {
  it('formats minutes and hours', () => {
    expect(formatCookingTime(null)).toBe('—');
    expect(formatCookingTime(35)).toBe('35 мин');
    expect(formatCookingTime(90)).toBe('1 ч 30 мин');
    expect(formatCookingTime(120)).toBe('2 ч');
  });
});

describe('sortRecipes', () => {
  const recipes = [
    { title: 'Б', cooking_time: 40, nutrients_per_100g: { kcal: 300, protein: 5 } },
    { title: 'А', cooking_time: 20, nutrients_per_100g: { kcal: 100, protein: 20 } },
  ];

  it('sorts by title', () => {
    expect(sortRecipes(recipes, 'title').map((item) => item.title)).toEqual(['А', 'Б']);
  });

  it('sorts by calories ascending', () => {
    expect(sortRecipes(recipes, 'kcal-asc').map((item) => item.title)).toEqual(['А', 'Б']);
  });

  it('does not mutate the original list', () => {
    sortRecipes(recipes, 'title');
    expect(recipes.map((item) => item.title)).toEqual(['Б', 'А']);
  });
});

describe('profile mapping', () => {
  it('maps API profile to UI shape', () => {
    const profile = profileFromApi({
      selected_diet_id: 2,
      excluded_product_ids: [1],
      favorite_product_ids: [3],
      allowed_products: [{ id: 4, name: 'Овёс' }],
      profile: {
        low_sodium: true,
        low_sugar: false,
        low_fat: true,
        no_spicy: false,
        no_acidic: true,
        no_saturated_fat: false,
        target_kcal: 1800,
      },
    });

    expect(profile.selected_diet_id).toBe(2);
    expect(profile.flags.low_sodium).toBe(true);
    expect(profile.flags.low_fat).toBe(true);
    expect(profile.targets.target_kcal).toBe(1800);
    expect(profile.targets.target_sugar).toBe('');
  });

  it('maps UI profile to API payload', () => {
    const payload = profileToApi({
      selected_diet_id: 5,
      excluded_product_ids: [1],
      favorite_product_ids: [2],
      flags: {
        low_sodium: true,
        low_sugar: false,
        low_fat: false,
        no_spicy: true,
        no_acidic: false,
        no_saturated_fat: false,
      },
      targets: {
        target_kcal: '1800',
        target_protein: '',
        target_fat: null,
        target_carbs: undefined,
        target_sugar: 'abc',
        target_sodium_mg: 1500,
      },
    });

    expect(payload.selected_diet_id).toBe(5);
    expect(payload.low_sodium).toBe(true);
    expect(payload.no_spicy).toBe(true);
    expect(payload.target_kcal).toBe(1800);
    expect(payload.target_protein).toBeNull();
    expect(payload.target_sugar).toBeNull();
    expect(payload.target_sodium_mg).toBe(1500);
    expect(payload.preference_tags).toEqual([]);
  });
});
