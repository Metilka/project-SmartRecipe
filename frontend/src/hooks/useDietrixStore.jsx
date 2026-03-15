import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { dietLookup } from '../data/diets';
import { STORAGE_KEYS } from '../utils/constants';
import { deepClone, uid } from '../utils/helpers';
import { createBlankProfile } from '../utils/profile';

const DietrixContext = createContext(null);

const defaultSession = {
  mode: 'guest',
  selectedDietId: null,
  auth: {
    isAuthenticated: false,
    token: null,
    user: null,
  },
  profile: createBlankProfile(),
  toasts: [],
};

const readSession = () => {
  if (typeof window === 'undefined') {
    return defaultSession;
  }

  try {
    const raw = window.localStorage.getItem(STORAGE_KEYS.session);
    if (!raw) {
      return defaultSession;
    }
    return { ...defaultSession, ...JSON.parse(raw) };
  } catch (error) {
    return defaultSession;
  }
};

export function AppProvider({ children }) {
  const [session, setSession] = useState(readSession);

  useEffect(() => {
    window.localStorage.setItem(STORAGE_KEYS.session, JSON.stringify(session));
  }, [session]);

  const pushToast = (payload) => {
    const toast = {
      id: uid('toast'),
      type: payload.type || 'info',
      title: payload.title,
      message: payload.message,
    };

    setSession((current) => ({
      ...current,
      toasts: [...current.toasts, toast],
    }));

    window.setTimeout(() => {
      setSession((current) => ({
        ...current,
        toasts: current.toasts.filter((item) => item.id !== toast.id),
      }));
    }, 3400);
  };

  const dismissToast = (toastId) => {
    setSession((current) => ({
      ...current,
      toasts: current.toasts.filter((item) => item.id !== toastId),
    }));
  };

  const selectGuestDiet = (dietId) => {
    setSession((current) => ({
      ...current,
      mode: 'guest',
      selectedDietId: dietId,
    }));
  };

  const completeAuth = ({ token, user, profile }) => {
    setSession((current) => ({
      ...current,
      mode: 'auth',
      auth: {
        isAuthenticated: true,
        token,
        user,
      },
      profile: deepClone(profile || current.profile || createBlankProfile()),
      selectedDietId: user.dietId,
    }));
  };

  const logout = () => {
    setSession((current) => ({
      ...current,
      mode: 'guest',
      auth: defaultSession.auth,
      profile: createBlankProfile(),
    }));
  };

  const saveProfile = (profile) => {
    setSession((current) => ({
      ...current,
      profile: deepClone(profile),
    }));
  };

  const resetProfile = () => {
    setSession((current) => ({
      ...current,
      profile: createBlankProfile(),
    }));
  };

  const currentDietId = session.auth.isAuthenticated
    ? session.auth.user?.dietId || session.selectedDietId
    : session.selectedDietId;

  const currentDiet = currentDietId ? dietLookup[currentDietId] : null;

  const value = useMemo(
    () => ({
      session,
      currentDiet,
      isAuthenticated: session.auth.isAuthenticated,
      authUser: session.auth.user,
      profile: session.profile,
      toasts: session.toasts,
      actions: {
        selectGuestDiet,
        completeAuth,
        logout,
        saveProfile,
        resetProfile,
        pushToast,
        dismissToast,
      },
    }),
    [currentDiet, session]
  );

  return <DietrixContext.Provider value={value}>{children}</DietrixContext.Provider>;
}

export const useDietrixStore = () => {
  const context = useContext(DietrixContext);

  if (!context) {
    throw new Error('useDietrixStore must be used inside AppProvider');
  }

  return context;
};

