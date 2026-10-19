export default defineNuxtRouteMiddleware(async () => {
  // Both sessions are checked through same-origin APIs; no private SSR payload.
  if (import.meta.server) return;
  const nuxt = useNuxtApp();
  // On direct SSR visits, the mounted screen validates before loading private data.
  if (nuxt.isHydrating && nuxt.payload.serverRendered) return;
  const app = useNuxtApp(), account = app.$accessModel();
  try {
    await account.checkSession();
    if (!account.state.session) return navigateTo(account.state.failure ? '/inicio' : '/iniciar-sesion', { replace: true });
    if (!account.state.session.profile.onboardingCompleted) return navigateTo('/bienvenida', { replace: true });
  } finally { account.dispose(); }
  const reviewer = app.$reviewerAccessModel();
  try {
    await reviewer.checkSession();
    if (reviewer.state.session) return;
    if (!reviewer.state.failure) return navigateTo('/iniciar-sesion', { replace: true });
    if (reviewer.state.failure.kind === 'forbidden') return navigateTo('/inicio?reason=forbidden', { replace: true });
    // A transient reviewer failure is retriable in the moderation screen.
  } finally { reviewer.dispose(); }
});
