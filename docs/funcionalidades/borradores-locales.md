# Borradores locales de reportes

HU-15.1 / RF-32 / issue #47 · S6 · Android primero.
[ADR-131](../decisiones/131-borradores-locales-por-cuenta.md).

## Qué hace y recorrido

Conserva el formulario incompleto de mascota perdida propia, búsqueda comunitaria,
aviso de mascota encontrada y avistamiento. Al editar se guarda automáticamente;
al salir se espera su escritura. La siguiente visita recupera el mismo borrador.
Perfil → Borradores reúne únicamente los de la cuenta y este dispositivo; Retomar
abre el editor y contexto originales, incluso con sus dependencias remotas caídas.
Los formularios muestran Borrador / Sin publicar; no se confunde con un caso activo.
Descartar usa la confirmación compartida. Un envío con resultado incierto conserva
el comando original y se resuelve reintentando; en encontrado, el descarte conserva la RPC que confirma que no hay publicación activa antes de retirar el borrador local.

## Campos y reglas

UUID estable, fecha y hora independientes/incompletas, referencia de lugar y punto
privado; mascota seleccionada/versión/fotos seleccionadas para perdido; especie,
rasgos, tamaño/sexo/custodia y fotos nuevas para búsquedas/avisos; comentario,
ubicación/precisión y foto para avistamiento. Las fotos nuevas conservan bytes y
su identificador, sin depender de archivos temporales. Las de mascotas conservan
referencias y metadatos, sin URLs firmadas duraderas ni descarga offline de fichas.

Un borrador por cuenta/contexto. La vista de edición y los resultados tardíos se
separan por identidad. El borrador conserva el contenido exacto antes del envío;
una respuesta incierta se recupera congelada. El servidor sigue autorizando cada
intento y comprobando versión, fotos, estado y reglas de bloqueo.

## Persistencia y permisos

Drift/SQLite local esquema 1, base `report_drafts.sqlite` en soporte privado Android;
campos y evidencia se reemplazan atómicamente. Lecturas/escrituras/borrados ordenados.
Una confirmación antigua solo elimina el UUID correspondiente. Cuenta/contexto se
filtran antes de restaurar. No se almacenan credenciales, contacto ni perfiles ajenos.
Base/auxiliares excluidos del backup/transferencia Android. No hay esquema o despliegue
Supabase nuevo. Salir/cambiar cuenta conserva datos aislados; descartar elimina el
borrador propio; confirmar publicación lo retira; borrar datos/desinstalar los elimina.

El acceso global puede recuperar una bienvenida confirmada de esa misma cuenta
ante un fallo de transporte. La caché no autentica ni concede permisos y respeta
una respuesta remota negativa. Una cuenta nueva requiere conexión/bienvenida.

## Errores y reintentos

Un error de lectura no se convierte en borrador vacío ni sobrescribe el anterior.
Fallo de escritura conserva el formulario, muestra toast superior y permite
Reintentar guardado local; salir y publicar esperan una escritura confirmada.
Un fallo remoto conserva el UUID para el mismo reintento. Publicar confirmado puede
dejar el comando local si falla su borrado; reenviarlo confirma el mismo resultado.
Skeleton en lectura inicial, shimmer en acciones locales y sin dobles acciones.

## Dependencias y activación

Sin variables ni servicios nuevos. Dependencias nativas Drift, path/path_provider
y sqlite3_flutter_libs incluidas en pubspec/lock y registros de plugins. Requiere
actualizar el cliente Android; la web Nuxt conserva sus recorridos actuales.
No entrega HU-15.2 (cola automática) ni HU-15.3 (fichas/mapas en caché).

## Validación y pendientes

555/555 pruebas Flutter completas,63/63 focalizadas y18 regresiones nuevas de
persistencia/UI/acceso; formato664 archivos y análisis limpios. Capturas390×844
y320×350/texto200% revisadas con fuentes reales, sin overflow y con acciones
alcanzables por scroll. No equivale a aprobación visual del usuario.

Pruebas de archivo SQLite y ViewModels verifican cierre/reapertura, UUID, evidencia,
fecha parcial, aislamiento, fallos y reintento exacto. Renders de lista normales y
pequeños/texto ampliado y regresión de formularios; resultados finales en ESTADO.

El smoke nativo `apps/mobile/tool/offline_drafts_smoke.dart` usa una base separada
para ejecutarlo dos veces con force-stop entre ellas; no accede a cuenta/backend.
El intento de Android queda bloqueado por Gradle/Java: Unable to establish loopback
connection, reproducido también forzando IPv4. No se instaló ni reinició la app.
Pendiente reinicio Android real sin red con fotos, recorrido por Perfil/Borradores,
A→B/logout, publicación/reintento con Supabase y rendimiento con fotos máximas.
La evidencia local y fixtures no cierran la historia ni sustituyen esa demo.


23/10, HU-15.2/ADR-132: las confirmaciones de Publicar/Enviar pasan por la
[cola persistente de envíos](envios-pendientes.md), con estados veraces, UUID/payload
originales y recibo durable. App activa reintenta transitorios; rechazo/conflicto
requiere acción explícita. Un recibo validado tardío actualiza el editor; un
timeout no inicia otra petición mientras el intento original sigue activo.
Descarte respeta reclamación y autorización remota de encontrado. Validación
Android/Supabase real pendiente; no certifica cierre de esta historia.
