<script setup lang="ts">
import '../styles/login.css';
import { useStaggerReveal, vStaggerReveal } from '~/composables/useStaggerReveal';
import LoginInput from '../widgets/LoginInput.vue';
import SocialSignInButton from '../widgets/SocialSignInButton.vue';
import type { SocialProvider } from '#shared/features/moderation/domain/social_access';
const { revealStyle } = useStaggerReveal({ count: 6 });
const model = useNuxtApp().$accessModel();
const state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const route = useRoute();
const toast = useTemplateRef('toast');
const email = ref('');
const password = ref('');
const messages = {
  invalid: 'Revisa el correo y la contraseña.',
  unauthenticated: 'No pudimos iniciar sesión. Revisa el correo y la contraseña.',
  forbidden: 'Acceso denegado. Esta cuenta no tiene permiso para revisar denuncias.',
  unavailable: 'No pudimos conectar. Puedes volver a intentarlo.',
  conflict: 'La sesión cambió. Vuelve a intentarlo.',
};
let channel: BroadcastChannel | undefined;
let leaving = false;
async function social(provider: SocialProvider) {
  password.value='';
  const url=await model.signInWithProvider(provider);
  if(url)await navigateTo(url,{external:true});
}
async function login() {
  await model.login(email.value, password.value);
  password.value = '';
  if (state.value.session) channel?.postMessage('changed');
}
watch(() => state.value.notice, () => { if (state.value.failure) toast.value?.show(messages[state.value.failure.kind]); });
watch(() => state.value.session, async session => {
  if (session && !leaving) { leaving = true; await navigateTo('/moderacion', { replace: true }); }
});
onMounted(async () => {
  channel = new BroadcastChannel('eh-moderation');
  channel.onmessage = () => { password.value = ''; model.checkSession(); };
  await model.checkSession();
  if (!state.value.session && !state.value.failure) {
    if (route.query.reason === 'forbidden') toast.value?.show(messages.forbidden);
    if (route.query.reason === 'expired') toast.value?.show('La sesión expiró. Vuelve a iniciar sesión.');
    if (route.query.reason === 'oauth-failed') toast.value?.show('No pudimos completar el acceso. Vuelve a intentarlo.');
    if (route.query.reason === 'oauth-cancelled') toast.value?.show('Inicio de sesión cancelado.', null, false);
    if (route.query.reason === 'signed-out') toast.value?.show('Sesión cerrada.', null, false);
  }
});
onBeforeUnmount(() => { unsubscribe(); model.dispose(); password.value = ''; channel?.close(); });
</script>
<template>
  <main id="view" class="login-screen">
    <header class="login-heading">
      <a class="login-brand" href="/" aria-label="entre huellas · Inicio"><span class="login-brand-reveal stagger-reveal-item" v-stagger-reveal="revealStyle(0)"><span class="login-brand-icon"><img src="/brand.png" width="88" height="88" alt="" /></span></span><span class="login-brand-name stagger-reveal-item" v-stagger-reveal="revealStyle(1)">entre<br />huellas</span></a>
      <h1 class="stagger-reveal-item" v-stagger-reveal="revealStyle(2)">Inicia sesión</h1>
      <p class="stagger-reveal-item" v-stagger-reveal="revealStyle(3)">Más caminos de vuelta a casa.</p>
    </header>
    <TopToast ref="toast" />
    <form class="login-form stagger-reveal-item" v-stagger-reveal="revealStyle(4)" :aria-busy="state.checking || state.busy" novalidate @submit.prevent="login">
      <LoginInput v-model="email" label="Correo" :disabled="state.busy || state.checking || !!state.session" :invalid="state.failure?.kind==='invalid'" :notice="state.notice" />
      <LoginInput v-model="password" label="Contraseña" password :disabled="state.busy || state.checking || !!state.session" :invalid="state.failure?.kind==='invalid'" :notice="state.notice" />
      <ActionButton class="login-submit" type="submit" variant="primary" :working="state.busy && !state.socialProvider" :disabled="state.checking || !!state.session || !!state.socialProvider">Iniciar Sesión</ActionButton>
      <div class="login-divider"><span>o continúa con</span></div>
      <SocialSignInButton provider="google" :working="state.busy && state.socialProvider==='google'" :disabled="state.busy || state.checking || !!state.session" @choose="social" />
      <SocialSignInButton provider="facebook" :working="state.busy && state.socialProvider==='facebook'" :disabled="state.busy || state.checking || !!state.session" @choose="social" />
    </form>
    <p class="login-legal stagger-reveal-item" v-stagger-reveal="revealStyle(5)">Al iniciar sesión, aceptas nuestros <NuxtLink to="/terms">Términos de servicio</NuxtLink> y reconoces haber leído nuestra <NuxtLink to="/privacy">Política de privacidad</NuxtLink>.</p>
  </main>
</template>
