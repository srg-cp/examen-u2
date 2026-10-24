# Envíos pendientes y reintentos

HU-15.2 / RF-32 / issue #48 · S6 · Android primero.
[ADR-132](../decisiones/132-cola-persistente-de-envios-android.md).

## Qué hace y recorrido

Al confirmar Publicar/Enviar, el formulario valida y conserva el comando en la
cola del dispositivo antes de contactar el servidor. Si no se confirma, queda
pendiente con UUID y contenido originales. Con sesión/bienvenida preparadas, la
app activa comprueba los pendientes al entrar/volver y cada15s, respetando backoff
5/15/30/60/120s. No se promete trabajo con la app cerrada o en segundo plano.

Perfil → Envíos muestra pendiente/en curso, fallido o publicado e intentos. Ver
motivo abre toast; Reintentar envío original mantiene el comando; Revisar reporte
abre su contexto; Ver resultado consulta la ficha correspondiente. Borradores
conserva los incompletos y enlaza a Envíos. Los publicados con limpieza local
pendiente se excluyen de la lista de borradores por su recibo duradero.

Un rechazo deja fallido y detiene reintentos automáticos. Conflicto no crea otro
UUID ni reemplaza payload. Invalid/photo conocidos pueden corregirse en el editor
mediante una acción explícita de publicación; el servidor conserva su autorización.
Los estados/etiquetas son visibles; errores, motivos y validación usan toast superior.

## Persistencia, campos y permisos

SQLite/Drift esquema2 agrega `submission_queue`, migración1→2 sin perder borradores.
Cuenta/UUID, payload exacto, huella de campos/bytes, estado, intentos, fecha de
próximo intento, reclamación/proceso y recibo de publicación. Se conservan versión
de mascota, destino, instante, fotos seleccionadas y bytes nuevos. La huella no
incluye URLs firmadas ni datos decorativos del snapshot. Ningún token/contacto.

Una transacción vincula la clave al payload y reclama el envío. La respuesta
solo finaliza su nonce vigente. Reiniciar recupera reclamaciones de procesos
anteriores; en el mismo proceso un intento en curso se comparte. Cambio/logout
oculta la otra cuenta y detiene el recorrido antes de iniciar el siguiente elemento.
App vincula el sincronizador a la identidad autorizada por la política global;
las fuentes comprueban identidad entre las operaciones remotas.

El recibo se verifica mediante los casos de uso existentes, se guarda y luego se
retiran los bytes nuevos de la fila y el borrador correspondiente. Un replay ya
confirmado retorna el recibo sin HTTP. Si el borrado del borrador falla, su recibo
permanece autoritativo. No hay SQL/RPC/grants remotos nuevos.

## Errores, cancelación y reintentos

Respuesta ausente/inválida no confirma publicación. Error de disco antes de encolar
impide HTTP; si no puede guardarse un recibo, el comando original permite resolver
la incertidumbre al recuperar almacenamiento/reiniciar. Un error no equivale a vacío.

Descarte explícito solo retira una intención pendiente/fallida; en curso/publicado
se rechazan. No revoca una publicación remota. Encontrado conserva la RPC que
comprueba ausencia de publicación activa; si falla, conserva el borrador/UUID para
revisarlo y reintentarlo manualmente. No se descartan intentos inciertos en secreto.

El editor acepta el recibo validado tardío del mismo envío; antes de recibirlo
sigue pendiente. Reintentar mientras ese Future está activo se une a él. Campos
se bloquean durante una intención pendiente/en curso para conservar la huella.

## Activación y dependencias

Actualizar cliente Android con las dependencias de ADR-131 y crypto para SHA-256.
`main` habilita sincronización de la app normal; la composición de previews/tests
puede dejarla inactiva. Esquema local migra al abrir; sin variables/servicios nuevos.
HU-15.1 conserva su validación real pendiente; este incremento no la certifica ni
entrega caché de casos HU-15.3 o paridad offline de Nuxt.

## Validación y pendientes

573/573 pruebas Flutter finales, incluidas18 nuevas de cola/UI; análisis sin
incidencias y formato676 archivos sin cambios. Tres pruebas SQL focalizadas
PGlite/PostGIS pasan para perdido, encontrado y búsqueda, sin prueba alojada ni
suite SQL completa. `git diff --check` correcto. El router real activa sincronización
solo para cuenta preparada; el desmontaje de app libera su temporizador.

SQLite real y endpoint simulado con deduplicación verifican migración, reinicio,
reclamación en curso, evidencias, pérdida antes/después de persistir, replay,
conflicto, rechazo, revisión explícita, actor, cancelación y recibo inválido.
Pruebas del sincronizador y router comprueban habilitación, pausa, identidad y
visitante/bienvenida/cuenta preparada. Renders390×844 y320×350/texto200% revisados
con fuentes reales: estados, motivos, revisión y resultado alcanzables por scroll.

El smoke nativo `tool/offline_drafts_smoke.dart` tiene base separada y cubre borrador
más recuperación de reclamación entre procesos, sin cuenta/backend. La ejecución
Android sigue bloqueada antes de compilar: Gradle/Java devuelve Unable to establish
loopback connection. No hay APK nuevo ni instalación. Pendiente cortar red y
reiniciar Android con cuenta/fotos reales, pérdida de respuesta alrededor de commit
Supabase, concurrencia multiconexión, revocación/cambio de sesión, tiempos reales y
rendimiento máximo. No se cierra #48 ni su épica por la evidencia local.
