import { diets } from './diets';
import { mockRecipes, recipeLookup } from './mockRecipes';
import { createBlankProfile } from '../utils/profile';
import { rankRecipes, scoreRecipe } from '../utils/scoring';
import { STORAGE_KEYS } from '../utils/constants';
import { deepClone, sleep, sortRecipes, uid } from '../utils/helpers';
import { dietLookup } from './diets';

const DEMO_USER = {
  id: 'user-demo',
  email: 'demo@dietrix.local',
  password: 'demo123',
  dietId: 'D4',
  profile: {
    excludedProducts: ['walnuts'],
    medicalFlags: {
      gentleDigestion: false,
      strictLowSugar: false,
      strictLowSodium: true,
      reducedFat: false,
    },
    targetsDaily: {
      kcal: '2000',
      protein: '110',
      fat: '60',
      carbs: '200',
      sugar: '32',
      sodium: '1500',
    },
    preferences: ['fish', 'oven', 'vegetables', 'breakfast'],
    topN: 8,
  },
};

const readUsers = () => {
  if (typeof window === 'undefined') {
    return [DEMO_USER];
  }

  const raw = window.localStorage.getItem(STORAGE_KEYS.users);

  if (!raw) {
    window.localStorage.setItem(STORAGE_KEYS.users, JSON.stringify([DEMO_USER]));
    return [DEMO_USER];
  }

  try {
    const parsed = JSON.parse(raw);
    const hasDemo = parsed.some((user) => user.email === DEMO_USER.email);
    if (!hasDemo) {
      parsed.push(DEMO_USER);
      window.localStorage.setItem(STORAGE_KEYS.users, JSON.stringify(parsed));
    }
    return parsed;
  } catch (error) {
    window.localStorage.setItem(STORAGE_KEYS.users, JSON.stringify([DEMO_USER]));
    return [DEMO_USER];
  }
};

const writeUsers = (users) => {
  if (typeof window !== 'undefined') {
    window.localStorage.setItem(STORAGE_KEYS.users, JSON.stringify(users));
  }
};

const createToken = () => `mock-jwt-${uid('token')}`;

const maybeThrowSimulatedError = (payload) => {
  if (payload?.query?.trim().toLowerCase() === '!error') {
    throw new Error('Сервер рекомендаций временно недоступен. Попробуйте ещё раз.');
  }
};

export const mockApi = {
  async fetchDiets() {
    await sleep(420);
    return deepClone(diets);
  },

  async fetchGuestFeed({ dietId, query = '', sortBy = 'relevance' }) {
    await sleep(560);
    maybeThrowSimulatedError({ query });

    const filtered = mockRecipes.filter((recipe) => recipe.dietTags.includes(dietId));
    const queryFiltered = query
      ? filtered.filter((recipe) => {
          const haystack = `${recipe.title} ${recipe.description} ${recipe.preparationSummary}`.toLowerCase();
          return haystack.includes(query.toLowerCase());
        })
      : filtered;

    return deepClone(sortRecipes(queryFiltered, sortBy));
  },

  async fetchRecipe(recipeId) {
    await sleep(380);
    const recipe = recipeLookup[recipeId];

    if (!recipe) {
      throw new Error('Рецепт не найден.');
    }

    return deepClone(recipe);
  },

  async login({ email, password }) {
    await sleep(650);
    const users = readUsers();
    const user = users.find((item) => item.email.toLowerCase() === email.toLowerCase().trim());

    if (!user || user.password !== password) {
      throw new Error('Неверный email или пароль.');
    }

    return {
      token: createToken(),
      user: { id: user.id, email: user.email, dietId: user.dietId },
      profile: deepClone(user.profile),
    };
  },

  async register({ email, password, dietId }) {
    await sleep(720);
    const users = readUsers();

    if (!dietId) {
      throw new Error('Для регистрации необходимо выбрать диету.');
    }

    if (users.some((user) => user.email.toLowerCase() === email.toLowerCase().trim())) {
      throw new Error('Пользователь с таким email уже существует.');
    }

    const newUser = {
      id: uid('user'),
      email: email.trim(),
      password,
      dietId,
      profile: createBlankProfile(),
    };

    users.push(newUser);
    writeUsers(users);

    return {
      token: createToken(),
      user: { id: newUser.id, email: newUser.email, dietId: newUser.dietId },
      profile: deepClone(newUser.profile),
    };
  },

  async saveProfile({ userId, profile }) {
    await sleep(520);
    const users = readUsers();
    const index = users.findIndex((user) => user.id === userId);

    if (index >= 0) {
      users[index].profile = deepClone(profile);
      writeUsers(users);
    }

    return deepClone(profile);
  },

  async getRecommendations({ dietId, profile, filters = {} }) {
    await sleep(820);
    maybeThrowSimulatedError(filters);

    const diet = dietLookup[dietId];
    if (!diet) {
      throw new Error('Диета для персональной выдачи не найдена.');
    }

    const recipes = mockRecipes.filter((recipe) => recipe.dietTags.includes(dietId));
    return deepClone(rankRecipes(recipes, diet, profile, filters));
  },

  async getPersonalRecipe({ recipeId, dietId, profile }) {
    await sleep(430);
    const diet = dietLookup[dietId];
    const recipe = recipeLookup[recipeId];

    if (!diet || !recipe) {
      throw new Error('Не удалось подготовить персональную карточку рецепта.');
    }

    const scored = scoreRecipe(recipe, diet, profile);
    if (!scored.allowed) {
      return {
        recipe: deepClone(recipe),
        blocked: true,
        reasons: scored.reasons,
        diet,
      };
    }

    return {
      ...deepClone(scored),
      diet,
    };
  },

  async getDietSummary(dietId) {
    await sleep(260);
    const diet = dietLookup[dietId];
    if (!diet) {
      throw new Error('Диета не найдена.');
    }

    const recipeCount = mockRecipes.filter((recipe) => recipe.dietTags.includes(dietId)).length;

    return {
      diet,
      recipeCount,
      exampleMethods: [...new Set(mockRecipes.filter((recipe) => recipe.dietTags.includes(dietId)).map((recipe) => recipe.cookingMethodLabel))].slice(0, 3),
    };
  },
};
