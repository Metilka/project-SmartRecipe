import { useNavigate } from 'react-router-dom';
import AuthForm from '../components/AuthForm';
import { authApi } from '../api/auth';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function AuthPage() {
  const navigate = useNavigate();
  const { actions } = useDietrixStore();

  const handleLogin = async (payload) => {
    await authApi.login(payload);
    await actions.completeAuth();
    actions.pushToast({
      type: 'success',
      title: 'Вход выполнен',
      message: 'Переходим к персональному профилю.',
    });
    navigate('/profile');
  };

  const handleRegister = async (payload) => {
    await authApi.register(payload);
  };

  return <AuthForm onLogin={handleLogin} onRegister={handleRegister} />;
}
