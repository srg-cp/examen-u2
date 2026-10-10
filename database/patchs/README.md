# Patches manuales de Supabase

`004_patch_profile_avatars.sql` configura el bucket privado y las políticas de foto de perfil sin intentar alterar la tabla administrada `storage.objects`. Sustituye la ejecución fallida de la migración 003. Comprueba que RLS ya esté habilitado y aborta si no lo está; no cambia propietarios ni roles.

Pegar todo el archivo en una consulta nueva del SQL Editor del proyecto de desarrollo, con rol postgres. Quitar la selección de texto antes de Run para ejecutar la transacción completa. No ejecutar fragmentos del bloque DO. Se puede repetir y conserva las fotos existentes.

Es una salida generada, no otra fuente editable: `./database/scripts/Build-AvatarPatch.ps1` usa el plan 004 y las fuentes 010/012. `Build-RunAll.ps1` también la regenera. La migración 003 y fuente 011 se conservan como historial del intento fallido, pero no se deben usar para la activación manual. Antes de adoptar la CLI, conciliar su historial con las ejecuciones manuales.

005_patch_pets.sql: registro, consulta y edición privada de mascotas propias, generado por Build-PetsPatch.ps1 desde fuentes 013–018. Ejecutar archivo completo con rol postgres sobre esquema de acceso; no depende de Storage ni incorpora el patch anterior de avatar. No es una copia editable. Ver pruebas 005_pets_permissions.sql y ADR-010.
