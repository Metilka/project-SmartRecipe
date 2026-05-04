import { http } from './client';

// ---- Диеты ----------------------------------------------------------------

export const dietsApi = {
  // GET /diets → [{ id, name, description }]
  async list() {
    return http.get('/diets');
  },

  // GET /diets/:id/allowed-products → [{ id, name, category }]
  async allowedProducts(dietId) {
    return http.get(`/diets/${dietId}/allowed-products`);
  },
};

// ---- Продукты -------------------------------------------------------------

export const productsApi = {
  // GET /products → [{ id, name, category }]
  async list() {
    return http.get('/products');
  },
};

// ---- Рецепты --------------------------------------------------------------

export const recipesApi = {
  // GET /recipes?diet_id=&search=&cooking_method=&max_cooking_time=&page=&per_page=
  async list(params = {}) {
    return http.get('/recipes', {
      query: {
        diet_id: params.dietId,
        search: params.search,
        cooking_method: params.cookingMethod,
        max_cooking_time: params.maxCookingTime,
        page: params.page,
        per_page: params.perPage,
      },
    });
  },

  // GET /feed?diet_id= — гостевая лента только по диете
  async guestFeed({ dietId }) {
    return http.get('/feed', { query: { diet_id: dietId } });
  },

  // GET /recipes/:id — публичная детальная карточка
  async getById(recipeId) {
    return http.get(`/recipes/${recipeId}`);
  },

  // GET /recipes/:id/personal — персональная карточка (требует JWT)
  async getPersonal(recipeId) {
    return http.get(`/recipes/${recipeId}/personal`, { auth: true });
  },
};

// ---- Профиль --------------------------------------------------------------

export const profileApi = {
  // GET /profile → { selected_diet_id, allowed_product_ids, allowed_products,
  //                  excluded_product_ids, favorite_product_ids, profile: {...} }
  async get() {
    return http.get('/profile', { auth: true });
  },

  // PUT /profile — принимает:
  //   selected_diet_id?, excluded_product_ids?, favorite_product_ids?,
  //   low_sodium?, low_sugar?, low_fat?, no_spicy?, no_acidic?, no_saturated_fat?,
  //   target_kcal?, target_protein?, target_fat?, target_carbs?,
  //   target_sugar?, target_sodium_mg?, preference_tags?
  async update(payload) {
    return http.put('/profile', payload, { auth: true });
  },

  // POST /users/me/diet
  async selectDiet(dietId) {
    return http.post('/users/me/diet', { diet_id: dietId }, { auth: true });
  },
};

// ---- Рекомендации ---------------------------------------------------------

export const recommendationsApi = {
  // GET /recommendations?limit=
  async list({ limit = 20 } = {}) {
    return http.get('/recommendations', {
      auth: true,
      query: { limit },
    });
  },
};

// ---- Корзина (дневной план) -----------------------------------------------
// Backend держит корзину в памяти процесса, обнуляется при смене даты или
// при рестарте контейнера. Один пользователь — одна корзина на день.

export const basketApi = {
  // GET /basket → { entries: [...], totals: {...}, warnings: [...] }
  async get() {
    return http.get('/basket', { auth: true });
  },

  // POST /basket — добавить рецепт в корзину
  async add({ recipeId, servings = 1 }) {
    return http.post(
      '/basket',
      { recipe_id: recipeId, servings },
      { auth: true }
    );
  },

  // DELETE /basket — очистить корзину
  async clear() {
    return http.del('/basket', { auth: true });
  },
};
