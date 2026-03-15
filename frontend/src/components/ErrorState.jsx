export default function ErrorState({
  title = 'Не удалось загрузить данные',
  message,
  onRetry,
}) {
  return (
    <div className="error-state glass-panel" role="alert">
      <div className="error-state__badge">Ошибка</div>
      <div>
        <h3>{title}</h3>
        <p>{message}</p>
      </div>
      {onRetry && (
        <button className="aero-button danger" type="button" onClick={onRetry}>
          Повторить
        </button>
      )}
    </div>
  );
}
