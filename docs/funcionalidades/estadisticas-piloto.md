# Estadísticas agregadas del piloto

HU-16.1 / RF-35 / [#50](https://github.com/srg-cp/entrehuellas/issues/50).
Implementación local en `feature/pilot-statistics`; historia abierta.
24/10: el usuario confirma ejecución completa de039 en desarrollo; asignación
administrador y validación alojada siguen pendientes. No se reaplica el patch.
[ADR-136](../decisiones/136-estadisticas-agregadas-y-permiso-administrador.md).

## Qué hace y recorrido

Una cuenta administradora con bienvenida completada encuentra «Ver estadísticas»
en Inicio web. Abre `/administracion/estadisticas` desde el control real, mediante
el motor compartido de expansión fullscreen, y permite volver a Inicio.
La carga directa conserva marca y política global de acceso antes del render.

Desde/Hasta son fechas inclusivas de Lima, con mes actual como propuesta inicial;
Consultar aplica un período de máximo366 días. El período que acompaña los
resultados es el realmente consultado, aunque se editen los campos o falle
la siguiente consulta. Se muestran siete conteos:

| Conteo | Fuente y fecha |
| --- | --- |
| Casos perdidos publicados | lost_cases.created_at |
| Avisos y búsquedas publicados | found_cases.published_at; incluye vinculados, comunitarios y anteriores |
| Avistamientos recibidos | public_sightings.received_at |
| Recuperaciones confirmadas | case_closures.closed_at |
| Casos cancelados | deleted_at de publicación retirada sin recuperación registrada |
| Casos archivados | deleted_at de publicación retirada después de recuperación registrada |
| Denuncias recibidas | content_reports.submitted_at, resueltas o pendientes |

La clasificación cancelado/archivado fue confirmada por el usuario en este
incremento. No cambia el estado de los casos. Los borradores no cuentan; una
publicación sigue contando en su fecha aunque se retire/oculte después.
Solo los recibos confirman recuperación; no se infiere de resolved ni se
atribuyen recuperaciones a la app. Cierres antiguos sin recibo no se reconstruyen.
Una recuperación y su archivo pueden aparecer en períodos diferentes y no deben
sumarse como casos únicos. Todo esto se explica junto a las métricas.

## Persistencia, permisos y activación

Plan039/fuentes125–127; patch generado:
[039_patch_pilot_statistics.sql](../../database/patchs/039_patch_pilot_statistics.sql).
Requiere las fuentes previas existentes, incluidos casos, avistamientos, cierres
y denuncias. No requiere reaplicar patches anteriores ni activar FCM.

`platform_administrators` es una asignación privada independiente de moderación.
No hay autoasignación, herencia ni permisos por metadata. Asignar una cuenta
concreta exige operación administrativa explícita en desarrollo, por ejemplo:

```sql
-- Solo después de confirmar la cuenta autorizada y aplicar039.
insert into public.platform_administrators(user_id)
select id from auth.users where email = '<correo de la cuenta autorizada>'
on conflict (user_id) do nothing;
```

Verificar que la cuenta existe y quedó exactamente la asignación esperada.
El patch no asigna ninguna cuenta. Moderadores y cuentas comunes son rechazados.
Las RPC `require_platform_administrator` y `read_pilot_statistics` autorizan
cada operación; ninguna concede acceso directo a filas privadas de otras cuentas.
Las respuestas contienen solo agregados/período/zona, sin identificadores,
nombres, correos, salud, motivos ni coordenadas. Sin exportación o almacenamiento
local de estadísticas. No es HU-16.2 ni crea controles administrativos.

Nuxt usa cookie privada existente, JWT de usuario y comprobación de cuenta/
bienvenida antes de cada API; vincula actor, rechaza origen incorrecto y limita
cuerpo, respuesta y tiempo de consulta. Sin nueva variable de entorno o secreto
cliente. Para activar el recorrido remoto se necesita web actualizada además039.

## Errores y reintentos

Skeleton en consulta inicial; refresh conserva la última consulta confirmada con
shimmer. Consultar conserva etiqueta y bloquea dobles envíos durante trabajo.
Error/validación mediante toast superior y estado inválido de fechas. Reintentar
vuelve a consultar; cero conteos solo tras respuesta confirmada. Al revocar permiso,
expirar/cambiar cuenta o desmontar se retiran datos y se descartan respuestas
tardías. El retorno usa componentes/coordinador compartidos; movimiento reducido
no inventa animación.

## Validación local y pendiente

- 89/89 pruebas web, incluidas seis específicas; typecheck y build correctos.
- 33/33 pruebas de servidor Nuxt construido: acceso SSR, roles, actor, CSRF,
  períodos inválidos, fallo/reintento, revocación y payload sin datos privados.
- Dos pruebas SQL específicas con PostgreSQL/PostGIS local: visitantes/cuenta
  ordinaria/moderador rechazados, administrador autorizado, sin autoasignación,
  retirada de permiso, repetición de patch, fechas inválidas y máximas,
  límites05:00UTC de Lima, borradores excluidos, históricos y conteos exactos.
- Regresión SQL/PostGIS completa: **58/58 aprobadas**, cero omitidas; incluye
  repetición de run_all y permisos de los incrementos previos.
- Chrome local con backend fixture: acceso desde Inicio, apertura/cierre normales,
  movimiento reducido, fechas por teclado/foco, refresh/fallo conservando contenido,
  vacío confirmado y revocación sin datos residuales. Capturas1920/1440/731/390/320
  y320 con texto200%; sin overflow, errores JS, CSP o hidratación detectados.
- Fotografías/casos reales y permisos alojados no se certifican mediante fixtures.
  Pendientes: aplicar039 en desarrollo, asignar cuenta autorizada, demostrar
  administrador/moderador/usuario reales y contrastar conteos reproducibles;
  integrar/publicar el incremento. Safari/Firefox y aprobación visual pendientes.

Ejecución reproducible: `npm test`, `npm run typecheck`, `npm run build`,
`npm run test:server` en apps/platform; `npm test` en database/tests;
`node scripts/check-statistics-browser.mjs` con PLAYWRIGHT_MODULE/CHROME_PATH.
Logs locales ignorados: statistics-unit-validation.log, statistics-typecheck.log,
statistics-build.log, statistics-server-validation.log, statistics-browser-validation.log;
SQL en database/tests/pilot-statistics-full-sql.log y pilot-statistics-validation.log.
Capturas/fotogramas en apps/mobile/build/ui-preview/web-statistics. Son evidencia
local, no artefactos publicados. No se cierra #50/#16 ni se inicia #51.
