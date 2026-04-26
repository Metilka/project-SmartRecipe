import { useNavigate } from 'react-router-dom';
import AuthForm from '../components/AuthForm';
import { authApi } from '../api/auth';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function AuthPage() {
  const navigate = useNavigate();
  const { actions } = useDietrixStore();

  const handleLogin = async (payload) => {
    try {
      await authApi.login(payload);
      await actions.completeAuth();
      actions.pushToast({
        type: 'success',
        title: 'Вход выполнен',
        message: 'Переходим к персональному профилю.',
      });
      navigate('/profile');
    } catch (error) {
      // Бэкенд возвращает 403 с сообщением "Please verify your email before logging in"
      if (error.status === 403) {
        navigate('/auth/verify-pending', {
          state: { email: payload.email, reason: 'login' },
        });
        return;
      }
      throw error;
    }
  };

  const handleRegister = async (payload) => {
    await authApi.register(payload);
    actions.pushToast({
      type: 'success',
      title: 'Письмо отправлено',
      message: 'Проверьте почту и подтвердите адрес по ссылке.',
    });
    navigate('/auth/verify-pending', {
      state: { email: payload.email, reason: 'register' },
    });
  };

  return <AuthForm onLogin={handleLogin} onRegister={handleRegister} />;
}
