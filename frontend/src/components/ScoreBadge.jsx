export default function ScoreBadge({ score }) {
  const tone = score >= 85 ? 'success' : score >= 70 ? 'info' : score >= 55 ? 'warning' : 'danger';

  return (
    <div className={`score-badge score-badge--${tone}`.trim()}>
      <span>Оценка</span>
      <strong>{score}</strong>
    </div>
  );
}
