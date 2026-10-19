export default defineNuxtRouteMiddleware(async to => {
  if (import.meta.server) return;
  const model = useNuxtApp().$accessModel();
  try {
    await model.checkSession();
    const session = model.state.session;
    if (session) return navigateTo(session.profile.onboardingCompleted ? '/inicio' : '/bienvenida', { replace: true });
    if (model.state.failure) return navigateTo('/inicio', { replace: true });
    if (to.query.entry === 'checked') {
      const { entry: _, ...query } = to.query;
      return navigateTo({ path: to.path, query }, { replace: true });
    }
  } finally { model.dispose(); }
});
