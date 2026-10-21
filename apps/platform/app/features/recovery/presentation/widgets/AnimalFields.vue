<script setup lang="ts">
export type AnimalForm = { name: string; species: string; speciesDetail: string; size: string; sex: string; ageMonths: string | number | null; traits: string };
const model = defineModel<AnimalForm>({ required:true });
withDefaults(defineProps<{ pet?: boolean; disabled: boolean; invalid: readonly string[] }>(),{ pet:false });
</script>
<template>
  <div class="recovery-fields">
    <label v-if="pet">Nombre<input v-model="model.name" :disabled="disabled" maxlength="80" autocomplete="off" :aria-invalid="invalid.includes('name')" /></label>
    <label>Especie<select aria-label="Especie" v-model="model.species" :disabled="disabled" :aria-invalid="invalid.includes('species')"><option value="">Selecciona una especie</option><option value="dog">Perro</option><option value="cat">Gato</option><option value="other">Otra especie</option></select></label>
    <label v-if="model.species === 'other'">¿Qué especie?<input v-model="model.speciesDetail" :disabled="disabled" :maxlength="pet ? 60 : 40" :aria-invalid="invalid.includes('speciesDetail') || invalid.includes('species')" /></label>
    <label>Tamaño<select aria-label="Tamaño" v-model="model.size" :disabled="disabled" :aria-invalid="invalid.includes('size')"><option value="">{{ pet ? 'Selecciona un tamaño' : 'No lo sé' }}</option><option value="small">Pequeño</option><option value="medium">Mediano</option><option value="large">Grande</option></select></label>
    <label>Sexo (opcional)<select aria-label="Sexo (opcional)" v-model="model.sex" :disabled="disabled"><option value="">No lo sé</option><option value="male">Macho</option><option value="female">Hembra</option></select></label>
    <label v-if="pet">Edad en meses<input v-model="model.ageMonths" type="number" min="0" max="600" step="1" inputmode="numeric" :disabled="disabled" :aria-invalid="invalid.includes('ageMonths')" /></label>
    <label class="recovery-full">Rasgos distintivos<span class="recovery-textarea"><textarea aria-label="Rasgos distintivos" v-model="model.traits" maxlength="200" rows="4" :disabled="disabled" :aria-invalid="invalid.includes('traits')" /><span class="recovery-counter" aria-hidden="true">{{ model.traits.length }}/200</span></span></label>
  </div>
</template>
