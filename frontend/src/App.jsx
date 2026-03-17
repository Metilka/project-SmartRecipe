import AppRouter from './router';
import { AppProvider } from './hooks/useDietrixStore';

export default function App() {
  return (
    <AppProvider>
      <AppRouter />
    </AppProvider>
  );
}
