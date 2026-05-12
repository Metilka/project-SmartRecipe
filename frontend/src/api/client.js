// Базовый HTTP-клиент для общения с Flask API.
// В dev Vite проксирует все /api/* на backend (vite.config.js).
// В production nginx проксирует /api/* на backend контейнер.
// Поэтому BASE_URL = '/api', а бэкенд слушает без префикса.

const BASE_URL = '/api';

const STORAGE_ACCESS = 'dietrix_access_token';
const STORAGE_REFRESH = 'dietrix_refresh_token';

// ---- token storage ----------------------------------------------------------

export const tokenStore = {
  getAccess() {
    try {
      return window.localStorage.getItem(STORAGE_ACCESS) || null;
    } catch (e) {
      return null;
    }
  },
  getRefresh() {
    try {
      return window.localStorage.getItem(STORAGE_REFRESH) || null;
    } catch (e) {
      return null;
    }
  },
  setPair(access, refresh) {
    try {
      if (access) window.localStorage.setItem(STORAGE_ACCESS, access);
      if (refresh) window.localStorage.setItem(STORAGE_REFRESH, refresh);
    } catch (e) {
      /* ignore */
    }
  },
  setAccess(access) {
    try {
      if (access) window.localStorage.setItem(STORAGE_ACCESS, access);
    } catch (e) {
      /* ignore */
    }
  },
  clear() {
    try {
      window.localStorage.removeItem(STORAGE_ACCESS);
      window.localStorage.removeItem(STORAGE_REFRESH);
    } catch (e) {
      /* ignore */
    }
  },
};

// ---- error -----------------------------------------------------------------

export class ApiError extends Error {
  constructor(message, { status, data } = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.data = data;
  }
}

// ---- hooks to listen for auth events (logout on refresh failure) -----------

const listeners = new Set();
export const onUnauthorized = (fn) => {
  listeners.add(fn);
  return () => listeners.delete(fn);
};
const emitUnauthorized = () => listeners.forEach((fn) => fn());

// ---- refresh logic ---------------------------------------------------------

let refreshPromise = null;

async function refreshAccessToken() {
  const refresh = tokenStore.getRefresh();
  if (!refresh) {
    throw new ApiError('No refresh token', { status: 401 });
  }

  if (!refreshPromise) {
    refreshPromise = fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${refresh}` },
    })
      .then(async (res) => {
        if (!res.ok) {
          throw new ApiError('Refresh failed', { status: res.status });
        }
        const data = await res.json();
        tokenStore.setAccess(data.access_token);
        return data.access_token;
      })
      .finally(() => {
        // Следующий refresh можно запускать только после завершения текущего.
        setTimeout(() => {
          refreshPromise = null;
        }, 0);
      });
  }

  return refreshPromise;
}

// ---- core request function -------------------------------------------------

async function doFetch(method, path, { body, auth = false, retry = true, query } = {}) {
  const url = new URL(`${BASE_URL}${path}`, window.location.origin);
  if (query) {
    Object.entries(query).forEach(([k, v]) => {
      if (v !== undefined && v !== null && v !== '') {
        url.searchParams.set(k, v);
      }
    });
  }

  const headers = { 'Content-Type': 'application/json' };
  if (auth) {
    const token = tokenStore.getAccess();
    if (token) headers.Authorization = `Bearer ${token}`;
  }

  let response;
  try {
    response = await fetch(url.pathname + url.search, {
      method,
      headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
  } catch (networkError) {
    throw new ApiError(
      'Не удалось связаться с сервером. Проверьте, что backend запущен.',
      { status: 0 }
    );
  }

  // Читаем JSON и для успешных, и для ошибочных ответов.
  let data = null;
  const contentType = response.headers.get('content-type') || '';
  if (contentType.includes('application/json')) {
    try {
      data = await response.json();
    } catch (e) {
      data = null;
    }
  }

  if (response.ok) {
    return data;
  }

  // При 401 один раз обновляем access-токен и повторяем запрос.
  if (response.status === 401 && auth && retry) {
    try {
      await refreshAccessToken();
      return await doFetch(method, path, { body, auth, retry: false, query });
    } catch (refreshError) {
      tokenStore.clear();
      emitUnauthorized();
      throw new ApiError('Сессия истекла, войдите заново.', {
        status: 401,
        data,
      });
    }
  }

  const message =
    (data && (data.error || data.message)) ||
    `Ошибка ${response.status}`;

  throw new ApiError(message, { status: response.status, data });
}

export const http = {
  get: (path, opts) => doFetch('GET', path, opts),
  post: (path, body, opts = {}) => doFetch('POST', path, { ...opts, body }),
  put: (path, body, opts = {}) => doFetch('PUT', path, { ...opts, body }),
  del: (path, opts) => doFetch('DELETE', path, opts),
};
