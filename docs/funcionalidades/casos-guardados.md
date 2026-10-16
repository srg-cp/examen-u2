# Casos guardados

Módulo saved_cases. Ampliación explícita del16 de octubre de2026 de HU-07/RF-13, sin issue asignado. Patch020 aplicado según confirmación posterior del usuario; sin comprobación remota independiente ni historia cerrada. [ADR-050](../decisiones/050-casos-guardados-por-cuenta.md).

## Qué hace y recorrido

Entrar a una ficha pública disponible muestra marcador glass arriba a la derecha. Vacío: Guardar caso; lleno: Quitar de guardados. Estado consultado por cuenta al abrir y cambio confirmado únicamente tras servidor. Se recupera al volver/reiniciar una vez activado020. Disponible en origen lost/found, incluidas búsquedas comunitarias y avisos anteriores. No añade listado propio de guardados, seguimiento/push o descarga offline. Guardar no garantiza acceso posterior a un caso retirado/oculto.

## Reglas y campos

Referencia origen de almacenamiento + UUID, marca saved y versión; ausencia false/versión0. Elección independiente por cuenta. No guarda datos de mascota, fotos, coordenadas ni documentos; sin contadores públicos. Botón glass52, tooltip/semántica, shimmer real y sin reiniciar animación del contenido.

## Persistencia y permisos

Tabla Supabase saved_cases, RLS/grants de propietario y RPC autenticadas read_saved_case/set_saved_case, sin DML directo cliente. Guardar verifica proyecciones vigentes, sin ampliar permisos de resueltos/retirados. Clave incluye origen; quitar conserva tombstone/versionado y borrar cuenta elimina marcas.

## Errores y reintentos

Toast superior. Fallo de lectura permite reconsulta, sin cambiar estado desconocido. Fallo de escritura conserva marca confirmada y estado deseado/versión para repetir sin duplicar. Conflicto requiere reconsulta. Bloqueo de doble envío y descarte de respuestas de otra identidad/desmontaje. Sin éxito simulado ni reintentos automáticos/offline.

## Dependencias y activación

Requiere sesión y secuencia001–019; activar [migración020](../../supabase/migrations/20261016002000_saved_cases.sql) o [patch020](../../database/patchs/020_patch_saved_cases.sql). Fuentes070–073/plan020, generadores Build-SavedCasesPatch/Build-RunAll. Router compone botón mediante slots, SDK en data_sources e inyección bootstrap/main. Sin020 el marcador informa error de consulta.

## Validación y pendientes

Formato/análisis Flutter sin incidencias y SQL generado. Por petición del usuario no se ejecutan pruebas SQL/Flutter ni builds/renders. Aplicación de020 confirmada por el usuario, sin inspección remota del agente. Pendientes permisos A/B/anónimo, visibilidad/concurrencia/repetición, reinicio/cuenta, error/reintento y revisión Android/pequeño/texto ampliado; [ESTADO](../ESTADO.md). No cierra HU-07/HU-12/HU-15.3.
