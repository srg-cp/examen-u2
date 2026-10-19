<script setup lang="ts">
import ModerationScreen from '../features/moderation/presentation/screens/ModerationScreen.vue';
definePageMeta({middleware:'moderation-access'});
const withBack=ref(false);
useHead({title:'Moderación · Entre Huellas',meta:[{name:'robots',content:'noindex, nofollow, noarchive'}]});
</script>
<template><WebShell wide :with-back="withBack"><ModerationScreen @detail="withBack=$event" /></WebShell></template>
