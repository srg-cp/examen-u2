export default defineNuxtRouteMiddleware(async to => {
  if (import.meta.server) return;
  const model = useNuxtApp().$accessModel();
  try {
    await model.checkSession();
    const session = model.state.session;
    if (!session) {
      if (!model.state.failure || ['unauthenticated', 'conflict'].includes(model.state.failure.kind)) {
        return navigateTo('/iniciar-sesion', { replace: true });
      }
      // Connection failures retain the account screen's retry flow.
      return;
    }
    const destination = session.profile.onboardingCompleted ? '/inicio' : '/bienvenida';
    if (to.path !== destination) return navigateTo(destination, { replace: true });
  } finally { model.dispose(); }
});
