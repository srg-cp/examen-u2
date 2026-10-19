export default defineNuxtRouteMiddleware(async () => {
  // The API cookie is scoped to /api/moderation. SSR renders a public skeleton;
  // browser validation uses that cookie without exposing it to JavaScript.
  if (import.meta.server) return;
  const app = useNuxtApp();
  // On a direct visit, the screen checks after mounting to preserve SSR hydration.
  if (app.isHydrating && app.payload.serverRendered) return;
  const model = app.$accessModel();
  try {
    await model.checkSession();
    if (model.state.session) return;
    if (!model.state.failure) return navigateTo('/login', { replace: true });
    if (model.state.failure.kind === 'forbidden') return navigateTo('/login?reason=forbidden', { replace: true });
    // A network/server failure is retriable, never proof of missing access.
  } finally { model.dispose(); }
});
