import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

// Dev-режим: фронт говорит с бэкендом через /api
// Vite проксирует /api/* на backend (по умолчанию http://localhost:5000)
// При запуске в Docker роль прокси берёт nginx — см. frontend/nginx.conf

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const backendTarget = env.VITE_BACKEND_URL || 'http://localhost:5000';

  return {
    plugins: [react()],
    server: {
      port: 5173,
      host: '0.0.0.0',
      open: false,
      proxy: {
        // /api/foo → http://localhost:5000/foo
        '/api': {
          target: backendTarget,
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
    preview: {
      port: 4173,
      host: '0.0.0.0',
    },
  };
});
