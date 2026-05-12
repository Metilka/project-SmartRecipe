import { http, tokenStore } from './client';

export const authApi = {
  async register({ email, password }) {
    return http.post('/auth/register', { email, password });
  },

  async login({ email, password }) {
    const data = await http.post('/auth/login', { email, password });
    tokenStore.setPair(data.access_token, data.refresh_token);
    return data;
  },

  async logout() {
    try {
      await http.post('/auth/logout', undefined, { auth: true });
    } catch (e) {
      // Локальный выход должен сработать даже при недоступном API.
    } finally {
      tokenStore.clear();
    }
  },

  async me() {
    return http.get('/users/me', { auth: true });
  },

  async changePassword({ oldPassword, newPassword }) {
    return http.post(
      '/auth/change-password',
      { old_password: oldPassword, new_password: newPassword },
      { auth: true }
    );
  },
};
