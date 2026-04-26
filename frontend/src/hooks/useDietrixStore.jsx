import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { authApi } from '../api/auth';
import { dietsApi, profileApi } from '../api';
import { onUnauthorized, tokenStore } from '../api/client';
import { STORAGE_KEYS } from '../utils/constants';
import {
  createEmptyProfile,
  profileFromApi,
  uid,
} from '../utils/helpers';

const DietrixContext = createContext(null);

const readLocalSession = () => {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEYS.session);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch (e) {
    return null;
  }
};

const writeLocalSession = (payload) => {
  try {
    if (payload) {
      window.localStorage.setItem(STORAGE_KEYS.session, JSON.stringify(payload));
    } else {
      window.localStorage.removeItem(STORAGE_KEYS.session);
    }
  } catch (e) {
    /* ignore */
  }
};

export function AppProvider({ children }) {
  const persisted = readLocalSession();

  const [mode, setMode] = useState(persisted?.mode || 'guest');
  const [authUser, setAuthUser] = useState(persisted?.authUser || null);
  const [guestDietId, setGuestDietId] = useState(persisted?.guestDietId ?? null);
  const [diets, setDiets] = useState([]);
  const [dietsLoaded, setDietsLoaded] = useState(false);
  const [profile, setProfile] = useState(createEmptyProfile());
  const [bootstrapping, setBootstrapping] = useState(!!tokenStore.getAccess());
  const [toasts, setToasts] = useState([]);

  const toastTimersRef = useRef(new Map());

  const dismissToast = useCallback((toastId) => {
    setToasts((current) => current.filter((t) => t.id !== toastId));
    const timer = toastTimersRef.current.get(toastId);
    if (timer) {
      clearTimeout(timer);
      toastTimersRef.current.delete(toastId);
    }
  }, []);

  const pushToast = useCallback(
    (payload) => {
      const toast = {
        id: uid('toast'),
        type: payload.type || 'info',
        title: payload.title,
        message: payload.message,
      };
      setToasts((current) => [...current, toast]);
      const timer = setTimeout(() => dismissToast(toast.id), 3800);
      toastTimersRef.current.set(toast.id, timer);
    },
    [dismissToast]
  );

  useEffect(() => {
    if (mode === 'auth' && authUser) {
      writeLocalSession({ mode, authUser, guestDietId });
    } else if (mode === 'guest' && guestDietId) {
      writeLocalSession({ mode: 'guest', authUser: null, guestDietId });
    } else {
      writeLocalSession(null);
    }
  }, [mode, authUser, guestDietId]);

  // Грузим список диет (публично, нужно и гостям)
  useEffect(() => {
    let cancelled = false;
    dietsApi
      .list()
      .then((list) => {
        if (!cancelled) {
          setDiets(list || []);
          setDietsLoaded(true);
        }
      })
      .catch(() => {
        if (!cancelled) setDietsLoaded(true);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  // Восстанавливаем сессию по access_token из localStorage
  useEffect(() => {
    if (!tokenStore.getAccess()) {
      setBootstrapping(false);
      return;
    }

    let cancelled = false;
    (async () => {
      try {
        const me = await authApi.me();
        if (cancelled) return;
        setAuthUser({ id: me.id, email: me.email });
        setMode('auth');
        setProfile(profileFromApi(me));
      } catch (e) {
        if (cancelled) return;
        tokenStore.clear();
        setMode('guest');
        setAuthUser(null);
      } finally {
        if (!cancelled) setBootstrapping(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  // Обработка 401 от API-клиента
  useEffect(() => {
    const off = onUnauthorized(() => {
      setAuthUser(null);
      setMode('guest');
      setProfile(createEmptyProfile());
      pushToast({
        type: 'warning',
        title: 'Сессия истекла',
        message: 'Войдите снова, чтобы продолжить.',
      });
    });
    return off;
  }, [pushToast]);

  const selectGuestDiet = useCallback((dietId) => {
    setGuestDietId(dietId);
    setMode('guest');
  }, []);

  const completeAuth = useCallback(async () => {
    try {
      const me = await authApi.me();
      setAuthUser({ id: me.id, email: me.email });
      setMode('auth');
      setProfile(profileFromApi(me));
    } catch (e) {
      tokenStore.clear();
      setAuthUser(null);
      setMode('guest');
      throw e;
    }
  }, []);

  const logout = useCallback(async () => {
    await authApi.logout();
    setAuthUser(null);
    setMode('guest');
    setProfile(createEmptyProfile());
  }, []);

  const refreshProfile = useCallback(async () => {
    const data = await profileApi.get();
    const ui = profileFromApi(data);
    setProfile(ui);
    return ui;
  }, []);

  const setProfileLocal = useCallback((next) => {
    setProfile(next);
  }, []);

  const currentDietId =
    mode === 'auth' ? profile.selected_diet_id : guestDietId;

  const currentDiet = useMemo(() => {
    if (!currentDietId) return null;
    return diets.find((d) => d.id === currentDietId) || null;
  }, [diets, currentDietId]);

  const value = useMemo(
    () => ({
      mode,
      isAuthenticated: mode === 'auth' && !!authUser,
      authUser,
      diets,
      dietsLoaded,
      currentDiet,
      currentDietId,
      profile,
      toasts,
      bootstrapping,
      actions: {
        selectGuestDiet,
        completeAuth,
        logout,
        refreshProfile,
        setProfileLocal,
        pushToast,
        dismissToast,
      },
    }),
    [
      mode,
      authUser,
      diets,
      dietsLoaded,
      currentDiet,
      currentDietId,
      profile,
      toasts,
      bootstrapping,
      selectGuestDiet,
      completeAuth,
      logout,
      refreshProfile,
      setProfileLocal,
      pushToast,
      dismissToast,
    ]
  );

  return <DietrixContext.Provider value={value}>{children}</DietrixContext.Provider>;
}

export const useDietrixStore = () => {
  const ctx = useContext(DietrixContext);
  if (!ctx) throw new Error('useDietrixStore must be used inside AppProvider');
  return ctx;
};
