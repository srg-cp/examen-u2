# Fotos de mascotas — HU-04.1 / #30 y HU-04.2 / #31

Función autenticada para JPEG ya normalizado en Flutter. API: POST binario
`Content-Type: image/jpeg`, encabezados `x-pet-id`, `x-photo-id`, Authorization
de la sesión y apikey publicable. No aceptar owner, rutas, buckets ni URL remota
desde el cuerpo. Respuestas: 200 con proyección privada de foto confirmada;
401/403 sin autorización, 409 por UUID/contenido incompatible, 422 imagen
inválida, 503 fallo reintentable. Errores no contienen respuestas del proveedor.
Se limita cuerpo a 2 MiB y dimensiones a1280 antes de decode.

Desde la raíz del repo, con Deno2 instalado:

```powershell
deno run --config supabase/functions/pet-photo-process/deno.json --allow-read --allow-write supabase/functions/pet-photo-process/prepare-wasm.ts
deno check --config supabase/functions/pet-photo-process/deno.json supabase/functions/pet-photo-process/index.ts
deno test --config supabase/functions/pet-photo-process/deno.json --allow-read --allow-env supabase/functions/pet-photo-process/processor_test.ts supabase/functions/pet-photo-process/handler_test.ts
```

`prepare-wasm.ts` copia el WASM de la versión fijada en deno.json/deno.lock a
assets, ignorado por Git. El artefacto local pesa aproximadamente15 MiB.
config.toml incluye static_files. No desplegar sin prepararlo; no usar
despliegue de API/Dashboard que omita el archivo estático. Usar CLI con soporte
static_files y Docker según documentación de Supabase.

La instalación actual de Entre Huellas es autohospedada con Dokploy y no tiene
servicio functions (lista compartida por el usuario). Para ella seguir
[la preparación autohospedada](../../self-hosted/README.md): añadir el servicio,
instalar el paquete con WASM y comprobar la ruta de Kong. El comando
`supabase functions deploy --project-ref` corresponde a proyectos administrados
por Supabase, no a esta instalación.

Para activación en desarrollo: aplicar **patch012 completo** tras011 y preparar
WASM. El usuario ya reportó aplicado012; no repetirlo solo para instalar Edge.
La función usa SUPABASE_URL, SUPABASE_ANON_KEY y SUPABASE_SERVICE_ROLE_KEY
proporcionadas por el entorno de servidor, nunca dart-define ni archivos de la
app. `verify_jwt=false` va acompañado de Auth.getUser obligatorio en el handler;
no desactivar esa comprobación. No se ejecutó despliegue en esta tarea.

Antes de cerrar las historias: probar con usuarios A/B y anónimo, cámara
denegada con galería utilizable, archivo manipulado/tamaño/dimensiones por HTTP,
reintento con mismo UUID y bytes distintos, portada tras reinicio/retirada,
retirada fallida y baja de mascota. Descargar ambos derivados con sesión propia
y verificar ausencia de EXIF/GPS. Registrar memoria/CPU y arranque frío/caliente
en el runtime desplegado, incluidos1280² con detalle/ruido; no equiparar benchmark
local a esa cuota. Comprobar política permisiva adicional y que otro usuario no
puede firmar/editar/borrar archivos.

Los buckets nuevos siguen privados. Las fotos anteriores no se procesan
automáticamente; antes de exposición de casos deben reemplazarse o convertirse
explícitamente con lectura/decodificación segura. S3 deberá crear una proyección
pública solo de derivados verificados. Ver
[ADR-020](../../../docs/decisiones/020-procesamiento-y-principal-fotos.md).
