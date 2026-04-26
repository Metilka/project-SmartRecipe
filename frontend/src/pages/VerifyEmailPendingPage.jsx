import { useLocation, useNavigate } from 'react-router-dom';

export default function VerifyEmailPendingPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const email = location.state?.email;
  const reason = location.state?.reason || 'register';

  const title =
    reason === 'login'
      ? 'Почта ещё не подтверждена'
      : 'Подтвердите адрес электронной почты';

  const body =
    reason === 'login' ? (
      <>
        <p>
          Для аккаунта {email ? <strong>{email}</strong> : 'с этим адресом'} ещё не
          подтверждена почта. Без подтверждения войти нельзя.
        </p>
        <p>
          Откройте письмо, которое мы присылали при регистрации, и перейдите по
          ссылке из него. Ссылка действительна в течение 24 часов.
        </p>
      </>
    ) : (
      <>
        <p>
          Мы отправили письмо на{' '}
          {email ? (
            <strong>{email}</strong>
          ) : (
            'указанный вами адрес'
          )}
          . В письме есть ссылка — перейдите по ней, чтобы завершить регистрацию.
        </p>
        <p>
          Ссылка действительна в течение 24 часов. После подтверждения вернитесь
          сюда и войдите обычным способом.
        </p>
      </>
    );

  return (
    <div className="auth-window glass-panel">
      <div className="auth-window__titlebar">
        <span>Подтверждение почты</span>
        <div className="window-controls">
          <i />
          <i />
          <i />
        </div>
      </div>

      <div className="auth-form auth-form--verify">
        <div className="auth-verify__icon" aria-hidden="true">
          ✉
        </div>
        <h2 className="auth-verify__title">{title}</h2>
        <div className="auth-verify__body">{body}</div>

        <div className="form-helper-text">
          Не нашли письмо? Проверьте папку «Спам» или «Промо-акции».
        </div>

        <div className="auth-verify__actions">
          <button
            className="aero-button primary"
            type="button"
            onClick={() => navigate('/auth')}
          >
            Вернуться к входу
          </button>
          <button
            className="aero-button secondary"
            type="button"
            onClick={() => navigate('/guest/diets')}
          >
            Продолжить как гость
          </button>
        </div>
      </div>
    </div>
  );
}
