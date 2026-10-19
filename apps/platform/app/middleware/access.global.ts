import { routeAccess, sessionRedirect } from '#shared/routing/route_policy';

export default defineNuxtRouteMiddleware(async to => {
  // Server middleware uses the same policy before any page HTML is generated.
  if (import.meta.server) return;
  const access = routeAccess(to.path);
  if (access === 'public') return;
  const model = useNuxtApp().$accessModel();
  try {
    await model.checkSession();
    const session = model.state.session;
    if (!session) {
      if (model.state.failure) {
        if (access === 'guest') return navigateTo('/inicio', { replace: true });
        return; // Keep the existing retry screen for connection failures.
      }
      if (access !== 'guest') return navigateTo('/iniciar-sesion', { replace: true });
      if (to.query.entry === 'checked') {
        const { entry: _, ...query } = to.query;
        return navigateTo({ path: to.path, query }, { replace: true });
      }
      return;
    }
    const destination = sessionRedirect(access, session.profile.onboardingCompleted);
    if (destination) return navigateTo(destination, { replace: true });
    if (access === 'reviewer') {
      await model.loadManagementAccess();
      if (model.state.canReview === false) return navigateTo('/inicio?reason=forbidden', { replace: true });
      if (!model.state.session) return navigateTo('/iniciar-sesion', { replace: true });
      // A transient permission lookup failure retains the moderation retry UI.
    }
  } finally { model.dispose(); }
});
