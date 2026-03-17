import { clamp, createExplainSentence, deepClone, hasPreferenceTag, round } from './helpers';

const LIMIT_KEYS = ['kcal', 'fat', 'carbs', 'sugar', 'sodium'];
const BALANCE_KEYS = ['protein'];

const NUTRIENT_LABELS = {
  kcal: 'калорийность',
  protein: 'белок',
  fat: 'жиры',
  carbs: 'углеводы',
  sugar: 'сахар',
  sodium: 'натрий',
};

const MEDICAL_HARD_LIMITS = {
  strictLowSugar: { sugar: 5.4 },
  strictLowSodium: { sodium: 170 },
  reducedFat: { fat: 8 },
  gentleDigestion: { sugar: 7.5, fat: 8.5 },
};

const GENTLE_DISALLOWED_TAGS = ['fried-crust', 'spicy', 'rough-fiber'];

const getPer100gTargets = (diet, targetsDaily) => {
  const divisor = diet.referenceMassGPerDay / 100;

  return Object.fromEntries(
    Object.entries(targetsDaily).map(([key, value]) => [key, Number(value || 0) / divisor])
  );
};

const resolveEffectiveTargets = (diet, profile) => {
  const merged = { ...diet.defaultTargetsDaily };

  Object.entries(profile.targetsDaily || {}).forEach(([key, value]) => {
    if (value === '' || value == null) {
      return;
    }

    const numericValue = Number(value);

    if (Number.isNaN(numericValue)) {
      return;
    }

    if (diet.defaultTargetsDaily[key] == null) {
      merged[key] = numericValue;
      return;
    }

    if (key === 'protein') {
      merged[key] = Math.max(diet.defaultTargetsDaily[key], numericValue);
      return;
    }

    merged[key] = Math.min(diet.defaultTargetsDaily[key], numericValue);
  });

  const per100g = getPer100gTargets(diet, merged);

  Object.entries(profile.medicalFlags || {}).forEach(([flag, enabled]) => {
    if (!enabled || !MEDICAL_HARD_LIMITS[flag]) {
      return;
    }

    Object.entries(MEDICAL_HARD_LIMITS[flag]).forEach(([key, value]) => {
      per100g[key] = Math.min(per100g[key] || value, value);
    });
  });

  return {
    daily: merged,
    per100g,
  };
};

const checkHardFilter = (recipe, diet, profile, effectiveTargets) => {
  const reasons = [];
  const excludedProducts = new Set(profile.excludedProducts || []);

  if (!recipe.dietTags.includes(diet.id)) {
    reasons.push('Рецепт не относится к выбранной диете.');
  }

  if (recipe.ingredients.some((ingredient) => excludedProducts.has(ingredient.productId))) {
    reasons.push('В составе есть исключённые пользователем продукты.');
  }

  const forbiddenMethods = new Set(diet.cookingPolicy.forbidden || []);
  if (forbiddenMethods.has(recipe.cookingMethod)) {
    reasons.push('Метод приготовления запрещён правилами диеты.');
  }

  Object.entries(diet.hardLimitsPer100g || {}).forEach(([key, limit]) => {
    if (recipe.nutrientsPer100g[key] > limit) {
      reasons.push(`Превышен базовый лимит: ${NUTRIENT_LABELS[key] || key}.`);
    }
  });

  Object.entries(profile.medicalFlags || {}).forEach(([flag, enabled]) => {
    if (!enabled || !MEDICAL_HARD_LIMITS[flag]) {
      return;
    }

    Object.entries(MEDICAL_HARD_LIMITS[flag]).forEach(([key, limit]) => {
      if (recipe.nutrientsPer100g[key] > limit) {
        reasons.push(`Нарушен медицинский лимит: ${NUTRIENT_LABELS[key] || key}.`);
      }
    });
  });

  if (profile.medicalFlags?.gentleDigestion) {
    const hasGentleConflict = recipe.flags?.some((flag) => GENTLE_DISALLOWED_TAGS.includes(flag));
    if (hasGentleConflict) {
      reasons.push('Рецепт не подходит для щадящего пищеварения.');
    }
  }

  return {
    passed: reasons.length === 0,
    reasons,
    effectiveTargets,
  };
};

const computeIngredientScore = (recipe, diet, profile) => {
  let score = recipe.compatibility?.[diet.id] ?? 0.82;
  const notes = [];

  if (recipe.preferenceTags?.includes('vegetables')) {
    score += 0.03;
    notes.push('в составе есть овощной акцент');
  }

  if (recipe.preferenceTags?.includes('fish') && profile.preferences?.includes('fish')) {
    score += 0.04;
    notes.push('совпадает с предпочтением к рыбе');
  }

  if (recipe.preferenceTags?.includes('poultry') && profile.preferences?.includes('poultry')) {
    score += 0.04;
    notes.push('совпадает с предпочтением к птице');
  }

  if (profile.medicalFlags?.gentleDigestion && recipe.flags?.includes('rough-fiber')) {
    score -= 0.12;
    notes.push('содержит более грубую текстуру');
  }

  return {
    value: clamp(score),
    notes,
  };
};

const getMetricScore = (value, target, key) => {
  if (!target) {
    return 1;
  }

  if (LIMIT_KEYS.includes(key)) {
    if (value <= target) {
      const buffer = target - value;
      return clamp(0.88 + Math.min(buffer / Math.max(target, 1), 0.12));
    }

    const overflow = (value - target) / Math.max(target, 1);
    return clamp(1 - overflow * 1.2);
  }

  if (BALANCE_KEYS.includes(key)) {
    const delta = Math.abs(value - target) / Math.max(target, 1);
    return clamp(1 - delta);
  }

  return 1;
};

const computeNutrientScore = (recipe, effectiveTargets) => {
  const trackedKeys = ['kcal', 'protein', 'fat', 'carbs', 'sugar', 'sodium'];
  const metrics = trackedKeys.map((key) => ({
    key,
    score: getMetricScore(recipe.nutrientsPer100g[key], effectiveTargets.per100g[key], key),
  }));

  const value = metrics.reduce((sum, metric) => sum + metric.score, 0) / metrics.length;

  return {
    value: clamp(value),
    metrics,
  };
};

const computeCookingMethodScore = (recipe, diet) => {
  if (diet.cookingPolicy.recommended.includes(recipe.cookingMethod)) {
    return 1;
  }

  if (diet.cookingPolicy.allowed.includes(recipe.cookingMethod)) {
    return 0.74;
  }

  if (diet.cookingPolicy.forbidden.includes(recipe.cookingMethod)) {
    return 0.3;
  }

  return 0.62;
};

const computePersonalScore = (recipe, profile) => {
  const preferences = profile.preferences || [];

  if (!preferences.length) {
    return { value: 0.65, matches: [] };
  }

  const matches = preferences.filter((preference) => hasPreferenceTag(recipe, preference));
  const value = clamp(0.45 + matches.length * 0.17, 0, 1);

  return {
    value,
    matches,
  };
};

const createWhyItFits = (recipe, breakdown, personalScore, profile) => {
  const chunks = [];

  if (breakdown.nutrientScore >= 0.8) {
    chunks.push('нутриенты держатся в рабочем диапазоне для вашей цели');
  }

  if (breakdown.cookingMethodScore >= 0.9) {
    chunks.push('способ приготовления хорошо согласован с диетой');
  }

  if (personalScore.matches.length) {
    chunks.push(`совпали персональные предпочтения: ${personalScore.matches.join(', ')}`);
  }

  if (profile.medicalFlags?.strictLowSugar && recipe.nutrientsPer100g.sugar <= 5.4) {
    chunks.push('сахар остался в строгом персональном лимите');
  }

  if (!chunks.length) {
    chunks.push('рецепт прошёл фильтрацию и не нарушает выбранные ограничения');
  }

  return chunks;
};

export const scoreRecipe = (recipe, diet, profile) => {
  const effectiveTargets = resolveEffectiveTargets(diet, profile);
  const hardFilter = checkHardFilter(recipe, diet, profile, effectiveTargets);

  if (!hardFilter.passed) {
    return {
      recipe: deepClone(recipe),
      allowed: false,
      reasons: hardFilter.reasons,
      effectiveTargets,
    };
  }

  const ingredientScore = computeIngredientScore(recipe, diet, profile);
  const nutrientScore = computeNutrientScore(recipe, effectiveTargets);
  const cookingMethodScore = computeCookingMethodScore(recipe, diet);
  const personalScore = computePersonalScore(recipe, profile);

  const finalScore = round(
    100 *
      (0.5 * ingredientScore.value +
        0.35 * nutrientScore.value +
        0.05 * cookingMethodScore +
        0.1 * personalScore.value),
    1
  );

  const penalties = [];
  const nutrientPenaltyLabels = {
    kcal: 'Калорийность выше рекомендуемой нормы',
    protein: 'Белок выходит за рамки целевого диапазона',
    fat: 'Жиры превышают рекомендуемый уровень',
    carbs: 'Углеводы выше целевого значения',
    sugar: 'Сахар выше допустимого лимита',
    sodium: 'Натрий превышает безопасный порог',
  };

  nutrientScore.metrics.forEach((metric) => {
    if (metric.score < 0.68) {
      penalties.push(nutrientPenaltyLabels[metric.key] || `Показатель ${metric.key} вне допустимого диапазона`);
    }
  });

  if (ingredientScore.value < 0.78) {
    penalties.push('Состав рецепта допустим, но не самый подходящий для этой диеты.');
  }

  if (cookingMethodScore < 0.8) {
    penalties.push('Способ приготовления допустим, но не самый подходящий.');
  }

  const breakdown = {
    ingredientScore: round(ingredientScore.value, 2),
    nutrientScore: round(nutrientScore.value, 2),
    cookingMethodScore: round(cookingMethodScore, 2),
    personalScore: round(personalScore.value, 2),
  };

  return {
    recipe: deepClone(recipe),
    allowed: true,
    finalScore,
    breakdown,
    explain: createExplainSentence(breakdown),
    reasons: createWhyItFits(recipe, breakdown, personalScore, profile),
    penalties,
    effectiveTargets,
  };
};

export const rankRecipes = (recipes, diet, profile, filters = {}) => {
  const scored = recipes.map((recipe) => scoreRecipe(recipe, diet, profile)).filter((entry) => entry.allowed);

  let result = scored;

  if (filters.query) {
    const query = filters.query.toLowerCase();
    result = result.filter((entry) => {
      const haystack = `${entry.recipe.title} ${entry.recipe.description} ${entry.recipe.cookingMethodLabel}`.toLowerCase();
      return haystack.includes(query);
    });
  }

  if (filters.minScore) {
    result = result.filter((entry) => entry.finalScore >= Number(filters.minScore));
  }

  if (filters.method && filters.method !== 'all') {
    result = result.filter((entry) => entry.recipe.cookingMethod === filters.method);
  }

  if (filters.restriction && filters.restriction !== 'all') {
    result = result.filter((entry) => entry.recipe.restrictionTags?.includes(filters.restriction));
  }

  return result.sort((a, b) => b.finalScore - a.finalScore);
};
