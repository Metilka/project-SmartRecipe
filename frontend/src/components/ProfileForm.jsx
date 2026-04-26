import { useEffect, useMemo, useState } from 'react';
import {
  MEDICAL_FLAG_OPTIONS,
  TARGET_FIELD_OPTIONS,
} from '../utils/constants';
import Loader from './Loader';
import SectionCard from './SectionCard';

export default function ProfileForm({
  diets,
  currentDietId,
  allowedProducts,
  profile,
  onSave,
  onReset,
  onRefreshRecommendations,
  onChangeDiet,
  saving = false,
  dietChanging = false,
}) {
  const [formState, setFormState] = useState(profile);
  const [formError, setFormError] = useState('');

  useEffect(() => {
    setFormState(profile);
  }, [profile]);

  const productsSorted = useMemo(
    () => [...(allowedProducts || [])].sort((a, b) => a.name.localeCompare(b.name, 'ru')),
    [allowedProducts]
  );

  const handleToggleExcluded = (productId) => {
    setFormState((current) => {
      const isExcluded = current.excluded_product_ids.includes(productId);
      return {
        ...current,
        excluded_product_ids: isExcluded
          ? current.excluded_product_ids.filter((id) => id !== productId)
          : [...current.excluded_product_ids, productId],
        // Одновременно не может быть в favorites
        favorite_product_ids: isExcluded
          ? current.favorite_product_ids
          : current.favorite_product_ids.filter((id) => id !== productId),
      };
    });
  };

  const handleToggleFavorite = (productId) => {
    setFormState((current) => {
      const isFav = current.favorite_product_ids.includes(productId);
      return {
        ...current,
        favorite_product_ids: isFav
          ? current.favorite_product_ids.filter((id) => id !== productId)
          : [...current.favorite_product_ids, productId],
        excluded_product_ids: isFav
          ? current.excluded_product_ids
          : current.excluded_product_ids.filter((id) => id !== productId),
      };
    });
  };

  const handleToggleFlag = (flagId) => {
    setFormState((current) => ({
      ...current,
      flags: {
        ...current.flags,
        [flagId]: !current.flags[flagId],
      },
    }));
  };

  const handleTargetChange = (event) => {
    const { name, value } = event.target;
    setFormState((current) => ({
      ...current,
      targets: {
        ...current.targets,
        [name]: value,
      },
    }));
  };

  const validate = () => {
    const targetLimits = {
      target_kcal: { min: 800, max: 5000 },
      target_protein: { min: 20, max: 300 },
      target_fat: { min: 10, max: 200 },
      target_carbs: { min: 20, max: 500 },
      target_sugar: { min: 0, max: 150 },
      target_sodium_mg: { min: 200, max: 5000 },
    };

    for (const [key, value] of Object.entries(formState.targets)) {
      if (value === '' || value === null || value === undefined) continue;
      const num = Number(value);
      if (Number.isNaN(num) || num < 0) {
        return 'Все цели по нутриентам должны быть положительными числами.';
      }
      const limits = targetLimits[key];
      if (limits && (num < limits.min || num > limits.max)) {
        const label = TARGET_FIELD_OPTIONS.find((f) => f.id === key)?.label || key;
        return `Значение «${label}» должно быть от ${limits.min} до ${limits.max}.`;
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
        title="Текущая диета"
        subtitle="Смена диеты автоматически пересчитывает список разрешённых продуктов."
      >
        <div className="profile-summary-card">
          <div>
            <span>Номер диеты</span>
            <strong>№{currentDietId || '—'}</strong>
          </div>
          <label className="field-group field-group--compact">
            <span>Переключить диету</span>
            <select
              className="aero-select"
              value={currentDietId || ''}
              disabled={dietChanging}
              onChange={(e) => onChangeDiet(Number(e.target.value))}
            >
              {diets.map((d) => (
                <option key={d.id} value={d.id}>
                  №{d.id} — {d.name}
                </option>
              ))}
            </select>
          </label>
        </div>
      </SectionCard>

      {productsSorted.length > 0 && (
        <>
          <SectionCard
            title="Исключённые продукты"
            subtitle="Рецепты с этими продуктами не попадут в выдачу."
          >
            <div className="checkbox-tile-list">
              {productsSorted.map((product) => {
                const checked = formState.excluded_product_ids.includes(product.id);
                return (
                  <label
                    key={product.id}
                    className={`checkbox-tile ${checked ? 'is-active' : ''}`.trim()}
                  >
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() => handleToggleExcluded(product.id)}
                    />
                    <span>{product.name}</span>
                  </label>
                );
              })}
            </div>
          </SectionCard>

          <SectionCard
            title="Любимые продукты"
            subtitle="Рецепты с этими продуктами поднимаются в выдаче."
          >
            <div className="checkbox-tile-list">
              {productsSorted.map((product) => {
                const checked = formState.favorite_product_ids.includes(product.id);
                return (
                  <label
                    key={product.id}
                    className={`checkbox-tile checkbox-tile--fav ${checked ? 'is-active' : ''}`.trim()}
                  >
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() => handleToggleFavorite(product.id)}
                    />
                    <span>{product.name}</span>
                  </label>
                );
              })}
            </div>
          </SectionCard>
        </>
      )}

      <SectionCard
        title="Медицинские ограничения"
        subtitle="Ужесточают фильтрацию и корректируют целевые показатели."
      >
        <div className="toggle-list">
          {MEDICAL_FLAG_OPTIONS.map((option) => {
            const enabled = formState.flags[option.id];
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

      <SectionCard
        title="Дневные цели"
        subtitle="Пересчитываются в ориентиры на 100 г для оценки рецептов. Оставьте пустым, чтобы использовать значения диеты."
      >
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
                value={formState.targets[field.id] ?? ''}
                onChange={handleTargetChange}
                placeholder="Авто по диете"
              />
            </label>
          ))}
        </div>
      </SectionCard>

      {formError && <div className="form-alert form-alert--error">{formError}</div>}

      <div className="form-action-row">
        <button
          className="aero-button primary"
          type="button"
          onClick={submitSave}
          disabled={saving}
        >
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
          Сбросить изменения
        </button>
        <button className="aero-button" type="button" onClick={handleRefresh}>
          Сохранить и обновить рекомендации
        </button>
      </div>
    </div>
  );
}
