# Patches manuales de Supabase

027_patch_notifications.sql: HU-12.1/#40,12.2/#41,12.3/#42. Generado por
Build-NotificationsPatch.ps1 desde plan027/fuentes091–095. Requiere026 confirmado.
Aplicar solo027 completo en desarrollo; sin backfill ni secrets/cron.
Activación hosted/Firebase/Edge/planificador pendientes. Véase CONFIGURACION.

024_patch_public_sightings.sql: HU-10.1/#36, aplicar completo en desarrollo
después de023 y junto con el servidor Nuxt actualizado. RPC autorizada solo
service_role, tabla/evidencia privada, idempotencia y límites persistentes.
Generado por Build-PublicSightingsPatch.ps1 desde083–085/plan024; no editar
el artefacto ni volver a aplicar patches antiguos. Aplicación remota pendiente.

`004_patch_profile_avatars.sql` configura el bucket privado y las políticas de foto de perfil sin intentar alterar la tabla administrada `storage.objects`. Sustituye la ejecución fallida de la migración 003. Comprueba que RLS ya esté habilitado y aborta si no lo está; no cambia propietarios ni roles.

Pegar todo el archivo en una consulta nueva del SQL Editor del proyecto de desarrollo, con rol postgres. Quitar la selección de texto antes de Run para ejecutar la transacción completa. No ejecutar fragmentos del bloque DO. Se puede repetir y conserva las fotos existentes.

Es una salida generada, no otra fuente editable: `./database/scripts/Build-AvatarPatch.ps1` usa el plan 004 y las fuentes 010/012. `Build-RunAll.ps1` también la regenera. La migración 003 y fuente 011 se conservan como historial del intento fallido, pero no se deben usar para la activación manual. Antes de adoptar la CLI, conciliar su historial con las ejecuciones manuales.

005_patch_pets.sql: registro, consulta y edición privada de mascotas propias, generado por Build-PetsPatch.ps1 desde fuentes 013–018. Ejecutar archivo completo con rol postgres sobre esquema de acceso; no depende de Storage ni incorpora el patch anterior de avatar. No es una copia editable. Ver pruebas 005_pets_permissions.sql y ADR-010.

## Patch009: campos obligatorios de mascotas

009_patch_pet_required_fields.sql se genera con database/scripts/Build-PetRequiredFieldsPatch.ps1 y requiere008 aplicado. Ejecutar todo el archivo en Supabase de desarrollo al autorizar despliegue; no editarlo independientemente. Exige edad/tamaño/rasgos al crear o editar metadatos, con rasgos hasta200, conservando filas antiguas y sus operaciones de ciclo de vida. Fuentes034–035/ADR-016; tests locales no acreditan activación remota.

## 010 — Zonas de interés privadas

Generar con `../scripts/Build-InterestZonesPatch.ps1`. Aplicar completo [010_patch_interest_zones.sql](010_patch_interest_zones.sql) en Supabase de desarrollo con Auth/roles existentes. Crea tabla privada, RPC y permisos; no modifica mascotas ni requiere PostGIS. La salida deriva del plan010 y migración20261009001000; no editarla manualmente. Probado localmente, sin despliegue remoto en esta entrega.

## 011 — Preferencias de alertas

`011_patch_alert_preferences.sql` es generado por `../scripts/Build-AlertPreferencesPatch.ps1` desde plan011/SQL040–043 y migración20261010001100. Ejecutar **todo su contenido** en Supabase de desarrollo. Permite preferencias por cuenta con versión y RLS, sin activar entregas. Repetible sin borrar elecciones. Probar por separado `../tests/010_alert_preferences_permissions.sql`; la prueba usa usuarios ficticios y rollback. No editar el artefacto ni fuentes tras aplicarlo; cambios posteriores requieren otra migración.

## 012 — Procesamiento y principal de fotos

Generar mediante `database/scripts/Build-PetPhotoProcessingPatch.ps1`. Aplicar todo `012_patch_pet_photo_processing.sql` después de011 y coordinar activación con Edge pet-photo-process. No ejecutado remotamente por esta tarea. Añade derivados privados y principal; bloquea el circuito antiguo de cargas/publicación del cliente. Preparar WASM/desplegar según `supabase/functions/pet-photo-process/README.md` antes de actualizar la app. Mantiene fotos históricas privadas y sin processed_at inventado. No editar la salida: fuentes044–047/plan012.

## Patch013: casos perdidos

`013_patch_lost_cases.sql`, generado con `database/scripts/Build-LostCasesPatch.ps1`, se ejecuta completo después de012. Añade publicación autorizada/idempotente, historial/contador atómicos y proyección pública con derivados elegidos/verificados. Mantener buckets privados; sin DML cliente. Preparado y probado localmente; ejecución confirmada por el usuario el 10 de octubre de 2026, sin verificación remota por el agente. Ver CONFIGURACION y ADR-021.

## Patch014: casos encontrados

[014_patch_found_cases.sql](014_patch_found_cases.sql) se genera con Build-FoundCasesPatch.ps1 desde plan014/SQL052–055. Ejecutar completo después de013 y actualizar el handler existente pet-photo-process para x-found-case-id. No editar el artefacto ni volver a generar fuentes aplicadas con contenido diferente. Añade casos sin mascota/dueño conocido, fotos sanitizadas verificadas en buckets privados propios, publicación/evento idempotentes y limpieza autorizada de drafts. Preparado y probado localmente; activación remota pendiente. Ver CONFIGURACION/ADR-022.
# Límite de bloqueos al publicar perdido — patch015

Ejecutar completo [015_patch_lost_case_lock_timeout.sql](015_patch_lost_case_lock_timeout.sql), una vez aplicados los comandos de patch013. Regenerar con `./database/scripts/Build-LostCaseLockTimeoutPatch.ps1`. Plan015/fuente056 conserva historial previo y limita a5s cada espera de bloqueo dentro de la RPC; no cambia autorizaciones ni deduplicación. Su repetición y la de run_all están validadas localmente. No libera solicitudes antiguas ni acredita recuperación remota. La recuperación de la cola observada es un procedimiento operacional separado; no ejecutar scripts de cancelación como migraciones.
