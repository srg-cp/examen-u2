<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
definePageMeta({ middleware: ['account-access'] });
useHead({ title: 'Inicio · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="soft"><AccountScreen /></AmbientPageShell></template>

