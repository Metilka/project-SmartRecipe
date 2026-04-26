import { http, tokenStore } from './client';

export const authApi = {
  // POST /auth/register — возвращает { message, user_id }
  // Пользователь НЕ получает токены сразу, нужно подтвердить email
  async register({ email, password }) {
    return http.post('/auth/register', { email, password });
  },

  // POST /auth/login — возвращает { access_token, refresh_token, user_id }
  // Если почта не подтверждена → 403 с message "Please verify your email before logging in"
  async login({ email, password }) {
    const data = await http.post('/auth/login', { email, password });
    tokenStore.setPair(data.access_token, data.refresh_token);
    return data;
  },

  // POST /auth/logout
  async logout() {
    try {
      await http.post('/auth/logout', undefined, { auth: true });
    } catch (e) {
      // Даже если бэкенд недоступен, локально выходим
    } finally {
      tokenStore.clear();
    }
  },

  // GET /users/me — возвращает текущего пользователя
  async me() {
    return http.get('/users/me', { auth: true });
  },

  // POST /auth/change-password
  async changePassword({ oldPassword, newPassword }) {
    return http.post(
      '/auth/change-password',
      { old_password: oldPassword, new_password: newPassword },
      { auth: true }
    );
  },
};
