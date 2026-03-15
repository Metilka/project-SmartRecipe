import { useNavigate } from 'react-router-dom';
import AuthForm from '../components/AuthForm';
import { mockApi } from '../data/mockApi';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function AuthPage() {
  const navigate = useNavigate();
  const { actions } = useDietrixStore();

  const handleLogin = async (payload) => {
    const response = await mockApi.login(payload);
    actions.completeAuth(response);
    actions.pushToast({
      type: 'success',
      title: 'Вход выполнен',
      message: 'Переходим к персональному профилю.',
    });
    navigate('/profile');
  };

  const handleRegister = async (payload) => {
    const response = await mockApi.register(payload);
    actions.completeAuth(response);
    actions.pushToast({
      type: 'success',
      title: 'Аккаунт создан',
      message: 'Можно заполнить профиль и обновить рекомендации.',
    });
    navigate('/profile');
  };

  return <AuthForm onLogin={handleLogin} onRegister={handleRegister} />;
}
