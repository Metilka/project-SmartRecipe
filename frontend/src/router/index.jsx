import { BrowserRouter, Navigate, Outlet, Route, Routes } from 'react-router-dom';
import AppShell from '../layouts/AppShell';
import AuthWindowLayout from '../layouts/AuthWindowLayout';
import AuthPage from '../pages/AuthPage';
import GuestDietSelectionPage from '../pages/GuestDietSelectionPage';
import GuestFeedPage from '../pages/GuestFeedPage';
import GuestRecipePage from '../pages/GuestRecipePage';
import NotFoundPage from '../pages/NotFoundPage';
import PersonalRecipePage from '../pages/PersonalRecipePage';
import ProfilePage from '../pages/ProfilePage';
import RecommendationsPage from '../pages/RecommendationsPage';
import { useDietrixStore } from '../hooks/useDietrixStore';

function RequireAuth() {
  const { isAuthenticated } = useDietrixStore();
  return isAuthenticated ? <Outlet /> : <Navigate to="/auth" replace />;
}

export default function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/auth" element={<AuthWindowLayout />}>
          <Route index element={<AuthPage />} />
        </Route>

        <Route element={<AppShell />}>
          <Route path="/" element={<Navigate to="/guest/diets" replace />} />
          <Route path="/guest/diets" element={<GuestDietSelectionPage />} />
          <Route path="/guest/feed" element={<GuestFeedPage />} />
          <Route path="/guest/recipes/:recipeId" element={<GuestRecipePage />} />

          <Route element={<RequireAuth />}>
            <Route path="/profile" element={<ProfilePage />} />
            <Route path="/recommendations" element={<RecommendationsPage />} />
            <Route path="/recipes/:recipeId/personal" element={<PersonalRecipePage />} />
          </Route>

          <Route path="*" element={<NotFoundPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
