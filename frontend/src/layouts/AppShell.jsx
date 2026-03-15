import { Outlet } from 'react-router-dom';
import Header from '../components/Header';
import SidebarPanel from '../components/SidebarPanel';
import ToastStack from '../components/ToastStack';
import { useDietrixStore } from '../hooks/useDietrixStore';

export default function AppShell() {
  const { toasts, actions } = useDietrixStore();

  return (
    <div className="desktop-shell">
      <Header />
      <div className="desktop-shell__content">
        <main className="desktop-main">
          <Outlet />
        </main>
        <SidebarPanel />
      </div>
      <ToastStack toasts={toasts} onDismiss={actions.dismissToast} />
    </div>
  );
}
