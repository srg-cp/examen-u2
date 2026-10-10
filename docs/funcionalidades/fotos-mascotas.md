# Fotos de mascotas: cámara, galería, principal y procesamiento

Módulo: `pets`; servidor: `pet-photo-process`. HU-04 / RF-03;
[#30](../backlog/030-HU-04.1.md) y [#31](../backlog/031-HU-04.2.md).

## Qué hace y cómo se usa

En Registrar/Editar se seleccionan hasta tres fotos desde galería o cámara.
Cancelar la selección no añade una foto; denegar cámara no bloquea galería.
El botón de cámara se oculta al llegar al límite. Una selección nativa
interrumpida se recupera solo para la cuenta correspondiente.

La estrella elige la principal. Añadir, retirar o cambiar principal modifica
el borrador; el servidor se actualiza al pulsar Registrar mascota/Guardar cambios.
Descartar antes de guardar conserva las fotos confirmadas. Un fallo conserva
los pendientes para reintentar. Retirar la principal confirmada elige como
reemplazo la publicada más antigua. La principal se usa como portada de la mascota.

## Qué sucede al guardar

1. Flutter normaliza la imagen a JPEG, con dimensión máxima1280 y cuerpo hasta2MiB.
2. Envía bytes, ID de mascota e ID estable de foto a la función, usando su sesión.
3. El servidor comprueba la sesión y propiedad antes de leer/decodificar la imagen.
4. Valida tamaño, dimensiones y JPEG real. `magick.wasm` decodifica, corrige
   orientación y elimina EXIF/GPS; genera JPEG de hasta1280 y miniatura de hasta320.
5. Reserva por UUID/hash, guarda ambos derivados privados y confirma publicación
   solo cuando sus archivos cumplen los requisitos.
6. La app obtiene acceso firmado y muestra la foto confirmada.

`magick.wasm` es el motor de imágenes que ejecuta el servidor automáticamente.
No es un botón de Flutter ni un programa que el usuario deba ejecutar por foto.
El nombre interno published no implica acceso público: ambos buckets son privados.

## Persistencia, concurrencia y eliminación

El mismo UUID y contenido reconocen reintentos; otro contenido con el mismo ID
se rechaza. Principal única y versión independiente evitan sobrescribir una
selección concurrente; el conflicto permite consultar las fotos actuales.
Antes de borrar bytes se marca retirada; después se limpian los buckets y se
confirma. La marca histórica impide revivir una foto eliminada mediante reintento.

No existe transacción distribuida entre PostgreSQL y Storage. Una interrupción
puede dejar archivos privados incompletos que requieren revisión operativa.
Las fotos históricas no se convierten automáticamente ni reciben processed_at
inventado. Su eventual exposición en casos requiere derivados verificados y
una proyección pública autorizada.

## Activación en Dokploy

Requiere patch012 y el servicio functions con código, dependencias y WASM.
Kong envía `/functions/v1/` al servicio. El router incluye el WASM con staticPatterns
al crear el worker; copiar el archivo sin incluirlo en ese FS virtual no basta.
Las claves de servidor permanecen allí; Flutter usa sesión y clave publicable.

El procedimiento mantenido está en [supabase/self-hosted](../../supabase/self-hosted/README.md),
con generador de paquete, Compose y corrección del fallo NotFound observado.
Hot reload solo actualiza Flutter; no instala ni actualiza el servidor.

## Validación y lo pendiente

El usuario confirma patch012 aplicado, archivo instalado, servicio encendido,
HTTP401 anónimo y guardado desde la app tras corregir la inclusión del WASM.
Las pruebas locales de procesador real/handler/router suman10 aprobadas; los
resultados Flutter/SQL del incremento constan en [ESTADO](../ESTADO.md).

Ese guardado no acredita por sí solo todos los criterios: faltan comprobaciones
reales de reapertura, cámara/permisos, principal/retiro, usuarios A/B, EXIF/GPS de
archivos descargados y recursos bajo imágenes de detalle. Las historias no se
cierran automáticamente. Decisiones: [ADR-017](../decisiones/017-borrador-fotos-mascotas.md)
y [ADR-020](../decisiones/020-procesamiento-y-principal-fotos.md).
