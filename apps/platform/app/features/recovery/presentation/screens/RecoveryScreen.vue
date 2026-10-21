<script setup lang="ts">
import type { Pet, PetDraft, ReportDraft, ReportKind, ReportPhoto, Species } from '#shared/features/recovery/domain/recovery';
import AnimalFields from '../widgets/AnimalFields.vue';
import type { AnimalForm } from '../widgets/AnimalFields.vue';
import '../styles/recovery.css';
const props = defineProps<{ actor:string; section:'explore'|'pets'|'report' }>();
const model = useNuxtApp().$recoveryModel(props.actor), state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
const motion = useNuxtApp().$originTransition;
const query = reactive({ kind:'all',species:'all',status:'active' });
const editor = ref(false), petId = ref(''), version = ref(0);
const blank = (): AnimalForm => ({ name:'',species:'',speciesDetail:'',size:'',sex:'male',ageMonths:'',traits:'' });
const animal = ref(blank()), baseline = ref('');
const kind = ref<ReportKind>('own_loss'), selectedPet = ref(''), selectedTarget = ref(''), localDate = ref(''), place = ref('');
const point = ref<{ latitude:number;longitude:number }|null>(null), photos = shallowRef<readonly ReportPhoto[]>([]), fileNames = ref<string[]>([]);
const photoBusy = ref(false), uploadPetId = ref(''), reportId = ref('');
const savingDraft = ref(false), pendingPetPhoto = shallowRef<{ pet:string;photo:ReportPhoto }|null>(null);
const savedPet = computed(() => state.value.pets.find(p => p.id === selectedPet.value));
const invalid = computed(() => state.value.failure?.fields || []);
const frozen = shallowRef<{ draft:ReportDraft;photos:readonly ReportPhoto[] }|null>(null);
const blocked = computed(() => state.value.busy || photoBusy.value || savingDraft.value || !!frozen.value || !!state.value.receipt);
const dirty = computed(() => props.section === 'pets' ? !!pendingPetPhoto.value || (editor.value && JSON.stringify(animal.value) !== baseline.value) : props.section === 'report' && !state.value.receipt && !!(kind.value !== 'own_loss' || selectedPet.value || selectedTarget.value || localDate.value || place.value || point.value || photos.value.length || animal.value.traits || animal.value.species));
const title = computed(() => props.section === 'explore' ? 'Explorar' : props.section === 'pets' ? editor.value ? version.value ? 'Editar mascota' : 'Registrar mascota' : 'Mis mascotas' : 'Reportar');
const messages = { invalid:'Revisa los campos señalados. Completa la información y selecciona las fotos necesarias.',photo:'Elige imágenes JPEG, PNG o WebP de hasta 8 MB. Puedes usar hasta tres fotos.',unauthenticated:'Tu sesión terminó. Vuelve a iniciar sesión.',forbidden:'No tienes permiso para realizar esta operación.',conflict:'Los datos cambiaron. Actualiza la información antes de volver a enviarla.',unavailable:'No pudimos confirmar la operación. Conservamos tus datos para reintentar.' };
watch(() => state.value.notice, () => { if (state.value.failure) { toast.value?.show(messages[state.value.failure.kind]); if (state.value.failure.kind === 'unauthenticated') void navigateTo('/iniciar-sesion?reason=expired'); } });
watch(() => state.value.receipt, receipt => { if (receipt) { photos.value = []; frozen.value = null; fileNames.value = []; toast.value?.show('Reporte publicado. Gracias por ayudar.',null,false); } });
function load(more = false) { return model.load(props.section, { ...query },more); }
function editPet(p?: Pet) {
  editor.value = true; petId.value = p?.id || crypto.randomUUID(); version.value = p?.version || 0;
  animal.value = p ? { name:p.name,species:p.species,speciesDetail:p.speciesDetail || '',size:p.size || '',sex:p.sex || '',ageMonths:p.ageMonths ?? '',traits:p.traits } : blank();
  baseline.value = JSON.stringify(animal.value);
}
async function savePet() {
  const a = animal.value;
  const pet = await model.savePet({ id:petId.value,version:version.value,name:a.name,species:a.species as Species,speciesDetail:a.speciesDetail,size:a.size,sex:a.sex || null,ageMonths:a.ageMonths === '' || a.ageMonths === null ? null : Number(a.ageMonths),traits:a.traits } as PetDraft);
  if (pet) { editor.value = false; toast.value?.show('Mascota guardada.',null,false); }
}
async function selectFiles(event: Event, pet?: Pet) {
  const input = event.target as HTMLInputElement, files = [...(input.files || [])]; if (!files.length) return;
  photoBusy.value = true; uploadPetId.value = pet?.id || '';
  try {
    if (files.length > (pet ? 1 : 3) || files.some(f => !f.size || f.size > 8388608 || !['image/jpeg','image/png','image/webp'].includes(f.type))) { toast.value?.show(messages.photo); return; }
    const selected = []; for (const file of files) selected.push({ id:crypto.randomUUID(),bytes:new Uint8Array(await file.arrayBuffer()) });
    if (pet) { pendingPetPhoto.value = { pet:pet.id,photo:selected[0]! }; await retryPetPhoto(); }
    else { photos.value = selected; fileNames.value = files.map(f => f.name); }
  } catch { toast.value?.show(messages.photo); }
  finally { photoBusy.value = false; uploadPetId.value = ''; input.value = ''; }
}
async function retryPetPhoto() {
  const pending = pendingPetPhoto.value; if (!pending) return;
  uploadPetId.value = pending.pet;
  if (await model.uploadPetPhoto(pending.pet,pending.photo)) { pendingPetPhoto.value = null; toast.value?.show('Foto guardada.',null,false); }
  uploadPetId.value = '';
}
function snapshot() {
  const target = state.value.targets.find(c => c.source + ':' + c.id === selectedTarget.value), a = animal.value;
  const date = new Date(localDate.value);
  const draft: ReportDraft = { id:reportId.value,kind:kind.value,petId:savedPet.value?.id || null,petVersion:savedPet.value?.version || null,targetId:target?.id || null,communityTarget:target?.source === 'found',occurredAt:Number.isFinite(date.getTime()) ? date.toISOString() : '',latitude:point.value?.latitude ?? null,longitude:point.value?.longitude ?? null,place:place.value,species:a.species,speciesDetail:a.speciesDetail,size:a.size,sex:a.sex,traits:a.traits,photoIds:kind.value === 'own_loss' ? savedPet.value?.photoIds.slice(0,3) || [] : photos.value.map(p => p.id) };
  return { draft,photos:kind.value === 'own_loss' ? [] : photos.value };
}
async function send() {
  const value = frozen.value || snapshot();
  await model.send(value.draft,value.photos);
  if (state.value.failure && ['unavailable','conflict'].includes(state.value.failure.kind)) frozen.value = value;
}
async function remember() {
  if (savingDraft.value || state.value.busy) return;
  savingDraft.value = true;
  const value = frozen.value || snapshot();
  try { if (await model.remember({ ...value,frozen:!!frozen.value })) toast.value?.show('Borrador guardado en este navegador para tu cuenta.',null,false); }
  finally { savingDraft.value = false; }
}
const confirm = shallowRef<{ resolve:(value:boolean)=>void }|null>(null);
function ask() { return new Promise<boolean>(resolve => { confirm.value = { resolve }; }); }
function answer(value:boolean) { const pending = confirm.value; confirm.value = null; pending?.resolve(value); }
async function cancelEditor() { if (state.value.busy || (dirty.value && !await ask())) return; await motion.closeLocal(() => { editor.value = false; }); }
onBeforeRouteLeave(async () => !state.value.busy && !photoBusy.value && !savingDraft.value && (!dirty.value || await ask()));
const beforeUnload = (event: BeforeUnloadEvent) => { if (dirty.value || state.value.busy) event.preventDefault(); };
onMounted(async () => {
  reportId.value = crypto.randomUUID(); window.addEventListener('beforeunload',beforeUnload);
  if (props.section === 'report') {
    const saved = await model.restoreDraft();
    if (saved) {
      const d = saved.draft; reportId.value = d.id; kind.value = d.kind; selectedPet.value = d.petId || ''; selectedTarget.value = (d.communityTarget ? 'found:' : 'lost:') + (d.targetId || ''); place.value = d.place;
      if (d.latitude !== null && d.longitude !== null) point.value = { latitude:d.latitude,longitude:d.longitude };
      if (d.occurredAt) { const date = new Date(d.occurredAt); if (Number.isFinite(date.getTime())) localDate.value = new Date(date.getTime()-date.getTimezoneOffset()*60000).toISOString().slice(0,16); }
      animal.value = { ...blank(),species:d.species,speciesDetail:d.speciesDetail,size:d.size,sex:d.sex,traits:d.traits }; photos.value = saved.photos; fileNames.value = saved.photos.map((_,i) => 'Foto ' + (i+1));
      if (saved.frozen) frozen.value = { draft:d,photos:saved.photos };
      toast.value?.show('Restauramos tu borrador de este navegador.',null,false);
    }
  }
  void load();
});
onBeforeUnmount(() => { unsubscribe(); model.dispose(); photos.value = []; frozen.value = null; pendingPetPhoto.value = null; answer(false); window.removeEventListener('beforeunload',beforeUnload); });
const photoUrl = (source:string,id:string) => '/api/recovery/photo?source=' + source + '&id=' + id;
const speciesLabel = (v:string) => ({ dog:'Perro',cat:'Gato',other:'Otra especie' }[v] || v);
const kindLabel = (v:string) => ({ lost:'En búsqueda',found:'En custodia',sighting:'Avistamiento' }[v] || v);
function imageFailed(event: Event) { (event.target as HTMLImageElement).hidden = true; }
</script>

<template>
  <section class="recovery-screen">
    <TopToast ref="toast" />
    <header class="account-welcome"><p class="eyebrow">Cada huella cuenta</p><h1>{{ title }}</h1><p v-if="section === 'explore'">Ayuda a encontrar su camino de vuelta a casa.</p><p v-else-if="section === 'pets' && !editor">Tus mascotas, contigo en web y móvil.</p></header>
    <ContentSkeleton v-if="state.loading" label="Consultando información" />
    <div v-else class="recovery-content" :class="{ refreshing:state.refreshing }" :aria-busy="state.refreshing">
      <template v-if="section === 'explore'">
        <form class="recovery-filters recovery-fields" @submit.prevent="load()">
          <label>Tipo<select aria-label="Tipo" v-model="query.kind" :disabled="state.refreshing"><option value="all">Todos</option><option value="lost">En búsqueda</option><option value="found">En custodia</option><option value="sighting">Avistamientos</option></select></label>
          <label>Especie<select aria-label="Especie" v-model="query.species" :disabled="state.refreshing"><option value="all">Todas</option><option value="dog">Perros</option><option value="cat">Gatos</option><option value="other">Otras especies</option></select></label>
          <label>Estado<select aria-label="Estado" v-model="query.status" :disabled="state.refreshing"><option value="active">Activos</option><option value="resolved">Resueltos visibles para ti</option><option value="all">Todos los visibles</option></select></label>
          <ActionButton type="submit" variant="primary" :working="state.refreshing">Aplicar filtros</ActionButton>
        </form>
        <StaggerReveal v-if="state.items.length" as="div" class="recovery-cards">
          <article v-for="item in state.items" :key="item.source + item.id" class="recovery-card">
            <div class="recovery-photo"><img v-if="item.hasPhoto" :src="photoUrl(item.source,item.id)" alt="" loading="lazy" @error="imageFailed" /><span v-else>{{ speciesLabel(item.species) }}</span></div>
            <div class="recovery-card-body"><p class="eyebrow">{{ kindLabel(item.kind) }} · {{ item.status === 'active' ? 'Activo' : 'Resuelto' }}</p><h2>{{ item.name || speciesLabel(item.species) }}</h2><p class="recovery-traits">{{ item.traits }}</p><p v-if="item.occurredAt" class="privacy">{{ new Date(item.occurredAt).toLocaleDateString('es-PE',{timeZone:'America/Lima'}) }}</p><p v-if="Number.isFinite(item.latitude) && Number.isFinite(item.longitude)" class="privacy">Zona aproximada: {{ item.latitude.toFixed(3) }}, {{ item.longitude.toFixed(3) }}</p></div>
          </article>
        </StaggerReveal>
        <p v-else-if="!state.failure" class="recovery-empty">No hay casos que coincidan con estos filtros.</p>
        <ActionButton v-if="state.cursor" :working="state.refreshing" @click="load(true)">Ver más casos</ActionButton>
      </template>
      <template v-else-if="section === 'pets'">
        <form v-if="editor" class="recovery-form" novalidate @submit.prevent="savePet">
          <AnimalFields v-model="animal" pet :disabled="state.busy" :invalid="invalid" />
          <div class="recovery-actions"><ActionButton type="submit" variant="primary" :working="state.busy">Guardar mascota</ActionButton><ActionButton :disabled="state.busy" @click="cancelEditor">Cancelar</ActionButton></div>
        </form>
        <template v-else>
          <div class="recovery-actions"><OriginActionButton variant="primary" :disabled="blocked" :action="() => editPet()">Registrar mascota</OriginActionButton><ActionButton :working="state.refreshing" :disabled="blocked" @click="load()">Actualizar</ActionButton></div>
          <StaggerReveal v-if="state.pets.length" as="div" class="recovery-cards">
            <article v-for="p in state.pets" :key="p.id" class="recovery-card">
              <div class="recovery-photo"><img v-if="p.photoIds.length" :key="p.photoIds.join()" :src="photoUrl('pet',p.id)" alt="" loading="lazy" @error="imageFailed" /><span v-else>{{ speciesLabel(p.species) }}</span></div>
              <div class="recovery-card-body"><h2>{{ p.name }}</h2><p class="privacy">{{ speciesLabel(p.species) }}<template v-if="p.ageMonths !== null"> · {{ p.ageMonths }} meses</template></p><p class="recovery-traits">{{ p.traits }}</p><div class="recovery-actions"><OriginActionButton :disabled="blocked" :action="() => editPet(p)">Editar</OriginActionButton><label class="secondary recovery-file" :class="{ working:state.busy && uploadPetId === p.id }">Añadir foto<input type="file" accept="image/jpeg,image/png,image/webp" :disabled="blocked || !!pendingPetPhoto || p.photoIds.length >= 3" :aria-label="'Añadir foto de ' + p.name" @change="selectFiles($event,p)" /></label><ActionButton v-if="pendingPetPhoto?.pet === p.id" :working="state.busy" @click="retryPetPhoto">Reintentar foto</ActionButton></div><p v-if="p.photoIds.length" class="privacy">{{ p.photoIds.length }} de 3 fotos</p></div>
            </article>
          </StaggerReveal>
          <p v-else-if="!state.failure" class="recovery-empty">Todavía no has registrado mascotas.</p>
        </template>
      </template>
      <template v-else>
        <div v-if="state.receipt" class="recovery-success"><h2>Reporte publicado</h2><p>Tu información ya está guardada en Entre Huellas.</p><NavigationLink to="/explorar" class="primary">Ir a Explorar</NavigationLink></div>
        <StaggerReveal v-else as="form" class="recovery-form" novalidate @submit.prevent="send">
          <div class="recovery-fields">
            <label class="recovery-full">¿Cómo quieres ayudar?<select aria-label="¿Cómo quieres ayudar?" v-model="kind" :disabled="blocked"><option value="own_loss">Se perdió mi mascota</option><option value="possible_loss">Vi una mascota posiblemente perdida</option><option value="sighting">Vi una mascota que están buscando</option><option value="with_reporter">Tengo a una mascota que están buscando</option></select></label>
            <template v-if="kind === 'own_loss'">
              <label class="recovery-full">Tu mascota<select aria-label="Tu mascota" v-model="selectedPet" :disabled="blocked" :aria-invalid="invalid.includes('pet') || invalid.includes('photos')"><option value="">Selecciona tu mascota</option><option v-for="p in state.pets" :key="p.id" :value="p.id">{{ p.name }}</option></select></label>
              <p class="privacy recovery-full">Se publicarán hasta tres fotos verificadas de la mascota. Puedes añadirlas desde Mis mascotas.</p>
              <NavigationLink v-if="!state.pets.length || (savedPet && !savedPet.photoIds.length)" to="/mis-mascotas" class="text-button">Registrar mascota o añadir fotos</NavigationLink>
            </template>
            <label v-else-if="kind !== 'possible_loss'" class="recovery-full">Búsqueda a la que ayudas<select aria-label="Búsqueda a la que ayudas" v-model="selectedTarget" :disabled="blocked" :aria-invalid="invalid.includes('target')"><option value="">Selecciona una búsqueda activa</option><option v-for="target in state.targets" :key="target.source + target.id" :value="target.source + ':' + target.id">{{ target.name || speciesLabel(target.species) }}</option></select></label>
            <label>Fecha y hora<input v-model="localDate" type="datetime-local" :disabled="blocked" :aria-invalid="invalid.includes('occurredAt')" /></label>
            <label>Referencia del lugar (privada)<input v-model="place" maxlength="120" :disabled="blocked" :aria-invalid="invalid.includes('place')" /></label>
          </div>
          <div class="recovery-map"><h2>¿Dónde ocurrió?</h2><p class="privacy">Marca el lugar en el mapa. La ficha pública muestra una zona aproximada; la referencia exacta permanece privada.</p><LocationMap :center="{latitude:-12.0464,longitude:-77.0428}" :point="point" :disabled="blocked" :invalid="invalid.includes('point')" @choose="point = $event" @failed="retry => toast?.show('No pudimos mostrar el mapa. Puedes reintentar.',retry)" /></div>
          <AnimalFields v-if="kind === 'possible_loss'" v-model="animal" :disabled="blocked" :invalid="invalid" />
          <div v-else-if="kind !== 'own_loss'" class="recovery-fields"><label class="recovery-full">¿Qué observaste?<span class="recovery-textarea"><textarea aria-label="¿Qué observaste?" v-model="animal.traits" maxlength="200" rows="4" :disabled="blocked" :aria-invalid="invalid.includes('traits')" /><span class="recovery-counter" aria-hidden="true">{{ animal.traits.length }}/200</span></span></label></div>
          <div v-if="kind !== 'own_loss'" class="recovery-upload"><label class="secondary recovery-file" :class="{ working:photoBusy,invalid:invalid.includes('photos') }">{{ kind === 'possible_loss' ? 'Elegir fotos' : 'Añadir fotos (opcional)' }}<input type="file" accept="image/jpeg,image/png,image/webp" multiple :disabled="blocked" aria-label="Fotos del reporte" @change="selectFiles($event)" /></label><p class="privacy">Hasta 3 fotos JPEG, PNG o WebP, de 8 MB cada una. Se eliminan los metadatos antes de publicar.</p><ul v-if="fileNames.length"><li v-for="name in fileNames" :key="name">{{ name }}</li></ul></div>
          <div class="recovery-actions"><ActionButton type="submit" variant="primary" :working="state.busy" :disabled="photoBusy || savingDraft">{{ frozen ? 'Reintentar el mismo envío' : 'Publicar reporte' }}</ActionButton><ActionButton :working="savingDraft" :disabled="state.busy || photoBusy" @click="remember">Guardar borrador</ActionButton></div>
        </StaggerReveal>
      </template>
      <ActionButton v-if="state.failure && !editor && !state.receipt && !frozen" :working="state.refreshing" :disabled="state.busy" @click="load()">Actualizar información</ActionButton>
    </div>
    <ConfirmationDialog :open="!!confirm" title="¿Salir sin guardar?" description="Los cambios que todavía no guardaste se descartarán." action="Salir" @answer="answer" />
  </section>
</template>
