import { createOriginTransition } from '~/utils/origin_transition';
export default defineNuxtPlugin(app => {
  const navigationActor = shallowRef<string|null>(null);
  const originTransition = createOriginTransition(() => navigationActor.value);
  const remove = app.$router.afterEach((to,from,failure) => { void originTransition.routeChanged(to.path,from.path,!!failure); });
  app.vueApp.onUnmount(() => { remove(); originTransition.clear(); });
  return { provide:{ originTransition,navigationActor } };
});
