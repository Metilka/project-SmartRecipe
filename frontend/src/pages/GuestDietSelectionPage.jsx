import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import DietCard from '../components/DietCard';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import SectionCard from '../components/SectionCard';
import { useDietrixStore } from '../hooks/useDietrixStore';
import { mockApi } from '../data/mockApi';

export default function GuestDietSelectionPage() {
  const navigate = useNavigate();
  const { currentDiet, actions } = useDietrixStore();
  const [diets, setDiets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadDiets = async () => {
    try {
      setLoading(true);
      setError('');
      const response = await mockApi.fetchDiets();
      setDiets(response);
    } catch (loadError) {
      setError(loadError.message || 'Не удалось получить список диет.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDiets();
  }, []);

  const handleSelect = (dietId) => {
    actions.selectGuestDiet(dietId);
    actions.pushToast({
      type: 'success',
      title: 'Диета выбрана',
      message: `Открыта лента для ${dietId}.`,
    });
    navigate('/guest/feed');
  };

  if (loading) {
    return <Loader fullScreen label="Загружаем доступные диеты…" />;
  }

  if (error) {
    return <ErrorState message={error} onRetry={loadDiets} />;
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Выбор диеты"
        subtitle="Пять режимов питания — выберите подходящий для просмотра каталога рецептов."
      >
        <div className="hero-banner">
          <div>
            <h3>Dietrix работает в двух режимах</h3>
            <p>
              Сейчас вы в гостевом сценарии: сначала выбираете диету, затем просматриваете ленту рецептов
              без учёта персонального профиля.
            </p>
          </div>
          {currentDiet && <div className="status-chip">Последний выбор: {currentDiet.id}</div>}
        </div>
      </SectionCard>

      <div className="diet-grid">
        {diets.map((diet) => (
          <DietCard key={diet.id} diet={diet} selected={currentDiet?.id === diet.id} onSelect={handleSelect} />
        ))}
      </div>
    </div>
  );
}
