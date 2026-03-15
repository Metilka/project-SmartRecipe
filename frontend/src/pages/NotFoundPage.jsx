import { useNavigate } from 'react-router-dom';
import EmptyState from '../components/EmptyState';

export default function NotFoundPage() {
  const navigate = useNavigate();

  return (
    <EmptyState
      title="Страница не найдена"
      message="Такой страницы не существует. Вернитесь к выбору диеты или к рекомендациям."
      actionLabel="На главную"
      onAction={() => navigate('/guest/diets')}
    />
  );
}
