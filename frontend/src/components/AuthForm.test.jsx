// @vitest-environment jsdom
import '@testing-library/jest-dom/vitest';
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';
import AuthForm from './AuthForm';

const setup = (props = {}) => {
  const user = userEvent.setup();
  const onLogin = props.onLogin || vi.fn().mockResolvedValue(undefined);
  const onRegister = props.onRegister || vi.fn().mockResolvedValue(undefined);

  const view = render(<AuthForm onLogin={onLogin} onRegister={onRegister} />);

  return { user, onLogin, onRegister, ...view };
};

const submitForm = (container) => {
  fireEvent.submit(container.querySelector('form'));
};

afterEach(() => {
  cleanup();
});

describe('AuthForm', () => {
  it('shows validation error for invalid email', async () => {
    const { container, user, onLogin } = setup();

    await user.type(screen.getByLabelText('Email'), 'wrong-email');
    await user.type(screen.getByLabelText('Пароль'), 'password123');
    submitForm(container);

    expect(await screen.findByText('Введите корректный email.')).toBeInTheDocument();
    expect(onLogin).not.toHaveBeenCalled();
  });

  it('shows validation error for short password', async () => {
    const { user, onLogin } = setup();

    await user.type(screen.getByLabelText('Email'), 'user@example.com');
    await user.type(screen.getByLabelText('Пароль'), 'short');
    await user.click(screen.getByRole('button', { name: 'Войти' }));

    expect(await screen.findByText('Пароль должен содержать минимум 8 символов.')).toBeInTheDocument();
    expect(onLogin).not.toHaveBeenCalled();
  });

  it('submits login payload', async () => {
    const onLogin = vi.fn().mockResolvedValue(undefined);
    const { user } = setup({ onLogin });

    await user.type(screen.getByLabelText('Email'), ' user@example.com ');
    await user.type(screen.getByLabelText('Пароль'), 'password123');
    await user.click(screen.getByRole('button', { name: 'Войти' }));

    await waitFor(() => {
      expect(onLogin).toHaveBeenCalledWith({
        email: 'user@example.com',
        password: 'password123',
      });
    });
  });

  it('switches to login and shows success after registration', async () => {
    const onRegister = vi.fn().mockResolvedValue(undefined);
    const { user } = setup({ onRegister });

    await user.click(screen.getByRole('button', { name: 'Регистрация' }));
    await user.type(screen.getByLabelText('Email'), 'new@example.com');
    await user.type(screen.getByLabelText('Пароль'), 'password123');
    await user.click(screen.getByRole('button', { name: 'Зарегистрироваться' }));

    await waitFor(() => {
      expect(onRegister).toHaveBeenCalledWith({
        email: 'new@example.com',
        password: 'password123',
      });
    });

    expect(screen.getByText('Регистрация прошла успешно. Теперь войдите в аккаунт.')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Войти' })).toBeInTheDocument();
    expect(screen.getByLabelText('Email')).toHaveValue('new@example.com');
    expect(screen.getByLabelText('Пароль')).toHaveValue('');
  });

  it('shows server error message when registration fails', async () => {
    const onRegister = vi.fn().mockRejectedValue(new Error('User already exists'));
    const { user } = setup({ onRegister });

    await user.click(screen.getByRole('button', { name: 'Регистрация' }));
    await user.type(screen.getByLabelText('Email'), 'old@example.com');
    await user.type(screen.getByLabelText('Пароль'), 'password123');
    await user.click(screen.getByRole('button', { name: 'Зарегистрироваться' }));

    expect(await screen.findByText('User already exists')).toBeInTheDocument();
    expect(screen.queryByText('Регистрация прошла успешно. Теперь войдите в аккаунт.')).not.toBeInTheDocument();
  });
});
