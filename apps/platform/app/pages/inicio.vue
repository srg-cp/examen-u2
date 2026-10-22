<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import NotificationBell from '../features/notifications/presentation/widgets/NotificationBell.vue';
useHead({ title: 'Inicio · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="soft"><AccountScreen><template #alerts="{session}"><NotificationBell :key="session.actor" :actor="session.actor" /></template></AccountScreen></AmbientPageShell></template>

