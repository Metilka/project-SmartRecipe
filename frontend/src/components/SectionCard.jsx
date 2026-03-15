export default function SectionCard({ title, subtitle, actions, className = '', children }) {
  return (
    <section className={`section-card glass-panel ${className}`.trim()}>
      {(title || subtitle || actions) && (
        <div className="section-card__header">
          <div>
            {title && <h2 className="section-card__title">{title}</h2>}
            {subtitle && <p className="section-card__subtitle">{subtitle}</p>}
          </div>
          {actions && <div className="section-card__actions">{actions}</div>}
        </div>
      )}
      <div className="section-card__body">{children}</div>
    </section>
  );
}
