<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import RecoveryScreen from '../features/recovery/presentation/screens/RecoveryScreen.vue';
useHead({ title:'Mis mascotas · Entre Huellas',meta:[{ name:'robots',content:'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell><AccountScreen v-slot="{ session }"><RecoveryScreen :key="session.actor" :actor="session.actor" section="pets" /></AccountScreen></AmbientPageShell></template>
