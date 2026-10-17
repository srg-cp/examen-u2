<script setup lang="ts">
import LandingPage from '../features/landing/presentation/screens/LandingPage.vue';
useSeoMeta({
  title: 'Entre Huellas | Más huellas juntas, más caminos de vuelta a casa',
  description: 'Conoce Entre Huellas, el proyecto de recuperación colaborativa que conecta a quienes buscan una mascota, encuentran una y quieren ayudar.',
  robots: 'index,follow', ogType: 'website', ogLocale: 'es_PE',
  ogTitle: 'Entre Huellas · Más caminos de vuelta a casa',
  ogDescription: 'Una comunidad con un propósito: ayudar a que vuelvan.',
  twitterCard: 'summary', twitterTitle: 'Entre Huellas', twitterDescription: 'Una comunidad para ayudar a que vuelvan.',
});
useHead({ link: [{ rel: 'canonical', href: 'https://entrehuellas.kormind.com/' }] });
</script>
<template><LandingPage /></template>
