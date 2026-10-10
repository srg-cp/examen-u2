# Casos de mascotas perdidas

Trazabilidad: **HU-05 / RF-05**, sprint S3, **issue #5**. Rama `feature/lost-pet-cases`. Implementación local; no historia cerrada ni despliegue confirmado. Contratos en [ADR-021](../decisiones/021-publicacion-casos-perdidos.md); evidencia en [ESTADO](../ESTADO.md).

## Qué hace y recorrido

Inicio → Reportar → Mascota perdida. Consulta las mascotas activas propias; si no hay ninguna permite abrir el registro y volver a consultar. Se elige mascota, se consultan su ficha/fotos actuales y se seleccionan de una a tres fotos públicas. La fecha y hora de desaparición se eligen con calendario/reloj; lugar por punto manual en mapa o coordenadas, sin solicitar GPS. La referencia del lugar queda privada.

Revisar publicación abre la vista previa con los datos que se harán públicos y el aviso para revisar información personal visible en rasgos/fotos. Publicar caso envía un UUID estable y conserva la etiqueta con shimmer durante el trabajo. Solo la respuesta válida del servidor abre Caso publicado → Ver ficha pública. Reportar → Mis casos permite recuperar publicaciones anteriores y abrir su proyección pública. No se publica directamente al elegir fotos o abrir vista previa.

## Campos y reglas

- Mascota propia, no archivada ni en eliminación; metadatos completos y versión vigente.
- Nombre/especie/tipo/tamaño/sexo opcional/edad/rasgos proceden de la ficha confirmada. Para cambiarlos abrir Editar mascota y luego volver a consultar fotos/ficha en el reporte.
- Fotos:1–3, distintas y elegidas explícitamente. El servidor exige estado publicado, processed_at y hash de procesamiento; fotos antiguas no verificadas requieren volver a guardarse desde el editor.
- Fecha/hora desde el año2000 y no posterior al reloj del servidor; Flutter convierte la hora local a UTC.
- Latitud−85..85 y longitud−180..180, finitas. Referencia privada1–120 caracteres Unicode tras normalizar.
- Solo un caso perdido activo por mascota. Reintento idéntico devuelve el caso; UUID con otros datos o versión desactualizada exige revisión.

## Persistencia y privacidad

Tablas `lost_cases` y `case_events`, RPC `publish_lost_case`, `read_public_lost_case` e `is_public_case_rendition`; [patch013](../../database/patchs/013_patch_lost_cases.sql). La publicación actualiza historial/contador/versión de mascota y el evento de publicación en una transacción. El historial impide eliminar definitivamente la mascota; el caso activo impide archivarla.

Datos públicos: copia de ficha permitida, fecha/hora, zona aproximada y fotos seleccionadas verificadas. Punto exacto, referencia del lugar y actor permanecen en fuente privada. No consulta documentos, salud, domicilio ni perfil/correo del responsable. La zona pública es el centro de una celda de0.01 grados; no representa el punto exacto. Las rutas de fotos incluyen UUID técnicos opacos, sin datos de perfil ni ubicación.

Los buckets siguen privados. Solo derivados seleccionados de casos activos admiten lectura pública mediante RLS; originales y fotos restantes no se exponen. URLs firmadas de5 minutos; retirar la foto impide nuevas consultas/firmas, pero enlaces existentes pueden seguir hasta su vencimiento. Retirada mantiene el ciclo de vida previo y puede reducir las fotos públicas disponibles. La pantalla móvil es protegida; el contrato RPC ya es público para la futura web QR, todavía sin web ni tokens/cartel de HU-08/HU-09.

## Errores y reintentos

Errores de campo y operación contextuales, sin SnackBar. Fallos de consulta distinguen error de vacío confirmado y ofrecen Reintentar. Consultar de nuevo conserva datos previos con progreso fino; un fallo conserva la última consulta. Cambio de cuenta oculta datos previos y descarta solicitudes tardías.

Fallos al publicar conservan el formulario y UUID. Respuesta ambigua congela el comando y permite reintentar exactamente o consultar Mis casos; nunca se permite editar ese comando y reutilizarlo como otro envío. Los rechazos conocidos permiten volver al formulario y consultar ficha/fotos. Salir sin publicar pide confirmar descarte; si hubo un envío ambiguo explica que puede estar persistido. No hay borrador persistente ni cola offline: quedan para HU-15.

## Dependencias y activación

Requiere mascotas y fotos012/Edge `pet-photo-process` funcionando. Aplicar patch013 completo en Supabase de desarrollo y reconstruir/actualizar la app; procedimiento en [CONFIGURACION](../CONFIGURACION.md). No requiere Edge nueva, push, permisos de ubicación ni PostGIS para esta publicación. PostGIS/cercanía son el incremento de HU-07.

## Validación pendiente

Pruebas locales Flutter/SQL y renders normales/pequeños se registran en ESTADO. El usuario confirmó la ejecución de patch013 el 10 de octubre de 2026. Falta demostrar publicación/reapertura/reinicio, dos cuentas, GPS denegado o ausente, doble envío/concurrencia con conexiones independientes, fallo/reintento y bytes públicos/originales privados contra Android/Supabase real. Las pruebas usan sustitutos y metadata de Storage, no acreditan el servicio remoto. Sin cerrar #5, desplegar ni actualizar GitHub en esta tarea.

## Evidencia local del incremento

234 pruebas Flutter y16 SQL locales aprobadas; formato/análisis correctos. Las9 pruebas nuevas cubren reintentos, cuenta/disposición, refresco, navegación/protección/descarte, privacidad presentada, dos tamaños y adaptador SDK. Renders con fuentes reales revisados; no hay datos ni teselas remotas en fixtures. No se ejecutó build Android por el agente; el usuario confirmó posteriormente la ejecución de patch013. HU-05 permanece pendiente de demo remota.
