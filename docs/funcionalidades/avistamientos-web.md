# Avistamientos desde la web pública

HU-10.1 / RF-11 / issue #36. Implementación local en
`feature/public-web-sighting`; historia abierta. [ADR-064](../decisiones/064-avistamientos-publicos-idempotentes.md).

## Qué hace y recorrido

Desde la ficha QR activa, «La vi · Reportar avistamiento» abre el formulario sin
cuenta ni instalación. Se registra fecha y hora locales del suceso, punto elegido
en mapa o GPS, comentario y foto opcionales. Centro inicial aproximado no se envía
sin confirmación. El mapa puede moverse con teclado y «Usar centro del mapa»;
denegar GPS mantiene la selección manual. Galería y captura de cámara son
alternativas; cancelar o no adjuntar foto no impide enviar.

Confirmación solo después de recibir el registro guardado. El formulario muestra
el estado confirmado y toast de éxito. Volver actualiza la ficha real. No resuelve
el caso, envía push ni implementa cronología/revisión HU-11 o envío Android HU-10.2.

## Reglas y campos

Fecha desde 2000, nunca futura. Más de 24 horas entre observación y recepción
se identifica como tardío; se conservan ambas fechas. Latitud −85..85, longitud
−180..180; manual con precisión nula, GPS con precisión de 0..100000m. Comentario
opcional hasta500 caracteres, sin datos personales recomendados por instrucción
visible. JPEG/PNG/WebP opcional hasta8MiB; servidor recodifica a JPEG1280px,
máximo1MiB, sin EXIF/XMP. No se acepta archivo por su nombre/MIME solamente.

## Persistencia y permisos

`public_sightings` privada, RPC solo servidor. UUID por visita al formulario y
hash de contenido protegen reintentos. Registro y evidencia bytea se guardan
atómicamente. Se conserva vínculo al caso/origen, no se inventa propietario del
avistamiento. Coordenadas, comentario y foto no se añaden al DTO público del QR.
La lectura autorizada por responsable/cronología se implementará con HU-11.

El servidor rechaza casos cerrados/borrados y enlaces revocados. Origen HTTP
exacto, límites de cuerpo/tiempo/concurrencia y rate limit por proceso; servidor
SQL limita confirmaciones por pseudónimo/caso entre réplicas. No guarda IP cruda.

## Errores y reintentos

Toast superior, invalid/Shake, etiquetas y datos conservados, sin texto de error
bajo inputs. Botón con etiqueta estable/shimmer y doble envío bloqueado.
Después de respuesta ambigua se bloquea edición y reintenta el payload original;
el servidor devuelve el recibo previo sin duplicar. Un error confirmado de foto
permite cambiarla/quitarla. Caso cerrado obliga a volver a la ficha.
Disposición cancela observadores y descarta respuestas de GPS antiguas. Cerrar
o recargar descarta el borrador: no se acredita guardado offline (HU-15).

## Dependencias y activación

Supabase001–023 operativos (022/023 confirmados previamente por el usuario).
Aplicar [patch024](../../database/patchs/024_patch_public_sightings.sql) o
[migración024](../../supabase/migrations/20261018002400_public_sightings.sql),
generados con Build-PublicSightingsPatch/Build-RunAll. Configurar PUBLIC_WEB_ORIGIN
con origen HTTPS exacto, sin slash final, en el servidor Nuxt; clave Supabase
solo servidor. Recompilar para incluir sharp y Leaflet. No se ha aplicado024,
desplegado ni modificado el entorno remoto en este incremento.

## Validación y pendiente

Resultados locales, capturas y limitaciones en [ESTADO](../ESTADO.md). Se prueban
reglas/VM/EXIF, RPC/roles/idempotencia/cierre/revocación/límites/repetición,
servidor de producción y navegador con datos/teselas fixture. Pendientes:
Supabase/Storage/proxy/TLS reales, concurrencia multiconexión, cámara/GPS en
teléfono físico y Safari/Firefox, QR desde otro teléfono y volumen/coste bytea.
La evidencia local no cierra HU-10.1 ni certifica publicación/contraste AA global.
Evidencia final:15 pruebas web y25 SQL aprobadas, typecheck/build limpios,
4 pruebas del servidor de producción y QA Chrome142 responsive aprobados.

Contraste medido en esta revisión: texto principal/crema17.08:1,
secundario/crema5.48:1, azul/celeste5.03:1. El texto blanco sobre el degradado
azul aprobado da1.97–3.62:1 (centro2.78:1), por debajo de4.5:1 para texto normal.
Se conserva la referencia cromática explícita de ADR-063; su adaptación accesible
queda como pendiente visual concreto, sin declarar AA. Registro hu10-contrast.log.
