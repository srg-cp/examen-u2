<script setup lang="ts">
import LoginScreen from '../features/access/presentation/screens/LoginScreen.vue';
definePageMeta({ middleware: ['guest-access'] });
useHead({ title: 'Iniciar sesión · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="strong"><LoginScreen /></AmbientPageShell></template>

