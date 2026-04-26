import { useNavigate } from 'react-router-dom';
import DietCard from '../components/DietCard';
import ErrorState from '../components/ErrorState';
import Loader from '../components/Loader';
import SectionCard from '../components/SectionCard';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function GuestDietSelectionPage() {
  const navigate = useNavigate();
  const { currentDiet, diets, dietsLoaded, actions } = useDietrixStore();

  const handleSelect = (dietId) => {
    actions.selectGuestDiet(dietId);
    actions.pushToast({
      type: 'success',
      title: 'Диета выбрана',
      message: `Открываем ленту рецептов.`,
    });
    navigate('/guest/feed');
  };

  if (!dietsLoaded) {
    return <Loader fullScreen label="Загружаем список диет…" />;
  }

  if (dietsLoaded && diets.length === 0) {
    return (
      <ErrorState
        title="Нет данных"
        message="Не удалось получить список диет. Проверьте, что backend запущен и база заполнена."
        onRetry={() => window.location.reload()}
      />
    );
  }

  return (
    <div className="page-stack">
      <SectionCard
        title="Выбор диеты"
        subtitle="Выберите режим питания, чтобы посмотреть рецепты из каталога."
      >
        <div className="hero-banner">
          <div>
            <h3>SmartRecipe работает в двух режимах</h3>
            <p>
              Сейчас вы в гостевом сценарии: сначала выберите диету, затем просматривайте
              ленту рецептов без учёта персонального профиля.
            </p>
          </div>
          {currentDiet && (
            <div className="status-chip">Последний выбор: №{currentDiet.id}</div>
          )}
        </div>
      </SectionCard>

      <div className="diet-grid">
        {diets.map((diet) => (
          <DietCard
            key={diet.id}
            diet={diet}
            selected={currentDiet?.id === diet.id}
            onSelect={handleSelect}
          />
        ))}
      </div>
    </div>
  );
}
