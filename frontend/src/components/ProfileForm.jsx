import { useEffect, useMemo, useState } from 'react';
import { MEDICAL_FLAG_OPTIONS, PREFERENCE_OPTIONS, TARGET_FIELD_OPTIONS } from '../utils/constants';
import { getProductName } from '../utils/helpers';
import Loader from './Loader';
import SectionCard from './SectionCard';

export default function ProfileForm({
  diet,
  profile,
  onSave,
  onReset,
  onRefreshRecommendations,
  saving = false,
}) {
  const [formState, setFormState] = useState(profile);
  const [formError, setFormError] = useState('');

  useEffect(() => {
    setFormState(profile);
  }, [profile]);

  const availableProducts = useMemo(
    () => diet.allowedProducts.map((productId) => ({ id: productId, label: getProductName(productId) })),
    [diet]
  );

  const handleToggleExcluded = (productId) => {
    setFormState((current) => {
      const exists = current.excludedProducts.includes(productId);
      return {
        ...current,
        excludedProducts: exists
          ? current.excludedProducts.filter((item) => item !== productId)
          : [...current.excludedProducts, productId],
      };
    });
  };

  const handleToggleFlag = (flagId) => {
    setFormState((current) => ({
      ...current,
      medicalFlags: {
        ...current.medicalFlags,
        [flagId]: !current.medicalFlags[flagId],
      },
    }));
  };

  const handleTargetChange = (event) => {
    const { name, value } = event.target;
    setFormState((current) => ({
      ...current,
      targetsDaily: {
        ...current.targetsDaily,
        [name]: value,
      },
    }));
  };

  const handleTogglePreference = (preferenceId) => {
    setFormState((current) => {
      const exists = current.preferences.includes(preferenceId);
      return {
        ...current,
        preferences: exists
          ? current.preferences.filter((item) => item !== preferenceId)
          : [...current.preferences, preferenceId],
      };
    });
  };

  const validate = () => {
    const disallowed = formState.excludedProducts.filter((productId) => !diet.allowedProducts.includes(productId));
    if (disallowed.length) {
      return 'Некоторые исключённые продукты не входят в список разрешённых для текущей диеты.';
    }

    const targetLimits = {
      kcal: { min: 800, max: 5000 },
      protein: { min: 20, max: 300 },
      fat: { min: 10, max: 200 },
      carbs: { min: 20, max: 500 },
      sugar: { min: 0, max: 150 },
      sodium: { min: 200, max: 5000 },
    };

    for (const [key, value] of Object.entries(formState.targetsDaily)) {
      if (value === '' || value == null) continue;
      const num = Number(value);
      if (Number.isNaN(num) || num < 0) {
        return 'Все цели по нутриентам должны быть положительными числами.';
      }
      const limits = targetLimits[key];
      if (limits && (num < limits.min || num > limits.max)) {
        return `Значение «${TARGET_FIELD_OPTIONS.find((f) => f.id === key)?.label || key}» должно быть от ${limits.min} до ${limits.max}.`;
      }
    }

    return '';
  };

  const submitSave = async () => {
    const validationError = validate();
    setFormError(validationError);
    if (validationError) return;
    await onSave(formState);
  };

  const handleRefresh = async () => {
    const validationError = validate();
    setFormError(validationError);
    if (validationError) return;
    await onRefreshRecommendations(formState);
  };

  return (
    <div className="profile-form-grid">
      <SectionCard
        title="Параметры профиля"
        subtitle="Исключения, ограничения, дневные цели и предпочтения влияют на подбор рецептов."
      >
        <div className="profile-summary-card">
          <div>
            <span>Текущая диета</span>
            <strong>{diet.id}</strong>
          </div>
          <p>{diet.description}</p>
        </div>
      </SectionCard>

      <SectionCard title="Исключённые продукты" subtitle="Рецепты с этими продуктами не попадут в выдачу.">
        <div className="checkbox-tile-list">
          {availableProducts.map((product) => {
            const checked = formState.excludedProducts.includes(product.id);
            return (
              <label key={product.id} className={`checkbox-tile ${checked ? 'is-active' : ''}`.trim()}>
                <input type="checkbox" checked={checked} onChange={() => handleToggleExcluded(product.id)} />
                <span>{product.label}</span>
              </label>
            );
          })}
        </div>
      </SectionCard>

      <SectionCard title="Медицинские ограничения" subtitle="Ужесточают фильтрацию и корректируют целевые показатели.">
        <div className="toggle-list">
          {MEDICAL_FLAG_OPTIONS.map((option) => {
            const enabled = formState.medicalFlags[option.id];
            return (
              <button
                key={option.id}
                className={`toggle-card ${enabled ? 'is-active' : ''}`.trim()}
                type="button"
                onClick={() => handleToggleFlag(option.id)}
              >
                <div>
                  <strong>{option.label}</strong>
                  <span>{option.helper}</span>
                </div>
                <i className="toggle-indicator" />
              </button>
            );
          })}
        </div>
      </SectionCard>

      <SectionCard title="Дневные цели" subtitle="Пересчитываются в ориентиры на 100 г для оценки рецептов.">
        <div className="targets-grid">
          {TARGET_FIELD_OPTIONS.map((field) => (
            <label key={field.id} className="field-group field-group--compact">
              <span>{field.label}</span>
              <input
                className="aero-input"
                type="number"
                min={field.min}
                max={field.max}
                step={field.step}
                name={field.id}
                value={formState.targetsDaily[field.id]}
                onChange={handleTargetChange}
                placeholder="Авто по диете"
              />
            </label>
          ))}
        </div>
      </SectionCard>

      <SectionCard title="Предпочтения" subtitle="Не блокируют рецепты, но повышают оценку подходящих блюд.">
        <div className="chip-selector">
          {PREFERENCE_OPTIONS.map((option) => {
            const active = formState.preferences.includes(option.id);
            return (
              <button
                key={option.id}
                className={`soft-chip soft-chip--button ${active ? 'is-active' : ''}`.trim()}
                type="button"
                onClick={() => handleTogglePreference(option.id)}
              >
                {option.label}
              </button>
            );
          })}
        </div>
      </SectionCard>

      {formError && <div className="form-alert form-alert--error">{formError}</div>}

      <div className="form-action-row">
        <button className="aero-button primary" type="button" onClick={submitSave} disabled={saving}>
          {saving ? <Loader inline label="Сохраняем…" /> : 'Сохранить'}
        </button>
        <button
          className="aero-button secondary"
          type="button"
          onClick={() => {
            setFormError('');
            onReset();
          }}
        >
          Сбросить
        </button>
        <button className="aero-button" type="button" onClick={handleRefresh}>
          Обновить рекомендации
        </button>
      </div>
    </div>
  );
}
