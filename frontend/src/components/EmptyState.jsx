export default function EmptyState({
  title = 'Ничего не найдено',
  message,
  actionLabel,
  onAction,
}) {
  return (
    <div className="empty-state glass-panel">
      <div className="empty-state__icon" aria-hidden="true">
        ⊘
      </div>
      <h3>{title}</h3>
      <p>{message}</p>
      {actionLabel && onAction && (
        <button className="aero-button primary" type="button" onClick={onAction}>
          {actionLabel}
        </button>
      )}
    </div>
  );
}
