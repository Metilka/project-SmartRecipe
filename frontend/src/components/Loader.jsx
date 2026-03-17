export default function Loader({ label = 'Загрузка данных…', inline = false, fullScreen = false }) {
  const content = (
    <div className={`loader ${inline ? 'loader--inline' : ''}`.trim()} role="status" aria-live="polite">
      <div className="loader__spinner" />
      <span>{label}</span>
    </div>
  );

  if (fullScreen) {
    return <div className="loader-screen">{content}</div>;
  }

  return content;
}
