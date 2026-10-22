<script setup lang="ts">
defineOptions({ inheritAttrs: false });
withDefaults(defineProps<{ modelValue: string | number | null; label: string; disabled?: boolean; invalid?: boolean; multiline?: boolean; maxlength?: number | string; rows?: number | string; type?: string; inset?: boolean }>(), { type: 'text', rows: 4 });
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
const id = useId();
const attrs = useAttrs();
const controlAttrs = computed(() => Object.fromEntries(Object.entries(attrs).filter(([key]) => key !== 'class' && key !== 'style')));
</script>
<template>
  <div class="sader-field sader-text-field" :class="[{ 'sader-invalid': invalid, 'sader-inset': inset, 'sader-multiline': multiline }, $attrs.class]">
    <span class="sader-label-space" aria-hidden="true">{{ label }}</span>
    <div class="sader-text-shell">
      <textarea v-if="multiline" :id="id" v-bind="controlAttrs" class="sader-text-input" :value="modelValue ?? ''" :disabled="disabled" :aria-invalid="invalid" :maxlength="maxlength" :rows="rows" placeholder=" " @input="emit('update:modelValue', ($event.target as HTMLTextAreaElement).value)" />
      <input v-else :id="id" v-bind="controlAttrs" class="sader-text-input" :type="type" :value="modelValue ?? ''" :disabled="disabled" :aria-invalid="invalid" :maxlength="maxlength" placeholder=" " @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)" />
      <label :for="id" class="sader-floating-label">{{ label }}</label>
      <fieldset class="sader-text-outline" aria-hidden="true"><legend><span>{{ label }}</span></legend></fieldset>
      <span v-if="multiline && maxlength" class="sader-counter" aria-hidden="true">{{ String(modelValue ?? '').length }}/{{ maxlength }}</span>
      <slot name="end" />
    </div>
  </div>
</template>
