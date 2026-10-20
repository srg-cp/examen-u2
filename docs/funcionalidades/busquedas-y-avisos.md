# Búsquedas y avisos vinculados

Excepción local20/10/2026, por petición explícita: el nombre de la ficha del
caso sobre fotografía conserva su diseño anterior a ADR-111: fuente del sistema,
blanco, tamaño48/peso800, altura1.05 y sombra negra suave, máximo dos líneas con
elipsis. Sin cápsula blanca. Solo CasePublicationPreview; los demás títulos
conservan Poppins400/32/gris. Acciones, panel y datos intactos.

Corrección20/10/2026: nombre principal de Ver ficha directamente sobre la
fotografía, sin cápsula blanca ni padding añadido. CasePublicationPreview
conserva Poppins400/32/gris, texto completo y scroll. Ajuste solicitado por el
usuario; sin cambios de datos, permisos o acciones.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Salida del reporte20/10: confirmación compartida sin origen abre/cierra como
popup160ms (fundido/escala leve), mostrando superficie y contenido juntos.
Cancelar, X, barrera y Atrás conservan el borrador; Salir mantiene el descarte
existente. Movimiento reducido inmediato, scroll/texto ampliado conservados.
Sin cambios de persistencia/permisos ni ampliación de HU-05/HU-06.
Validación visual Android pendiente; evidencia local en ESTADO.


**Auditoría de seguimiento18/10:** HU-05/#5 y HU-06/#6 en Done por entrega integrada y evidencia posterior. HU-13/#13 sigue In progress por integración/028/demo pendientes; cerrar las publicaciones no da por activado el cierre nuevo.

HU-10.2,18/10: la ficha abierta añade Reportar avistamiento mediante el módulo
[avistamientos Android](avistamientos-android.md), con comentario/foto opcionales
y evidencia privada. La vi o la encontré conserva el aviso público/custodia
existente y sus reglas. Los nuevos registros privados no se convierten en
found_cases ni se añaden a esa lista; su revisión pertenece a HU-11.

Implementación local por ajuste del usuario del11 de octubre de2026; no equivale al cierre de historias. [ADR-034](../decisiones/034-busquedas-y-avisos-vinculados.md).

## Qué hace y recorrido

Mascota perdida permite Mi mascota (elige ficha/fotos propias) u Otra mascota (describe una posiblemente perdida, sin registrarla como propia). Publicar abre la búsqueda. Mascota encontrada elige un caso abierto y La vi o La encontré y está conmigo. Desde ficha, La vi o la encontré abre el aviso con el caso preseleccionado. Se revisa y publica; la búsqueda sigue abierta. La ficha muestra sus avisos y permite consultarlos. Solo el autor de la búsqueda puede confirmar Ya fue recuperada mediante diálogo separado.

## Reglas y campos

Búsqueda propia conserva campos/fotos de la mascota y exige fecha/hora/punto/referencia y selección de fotos verificadas. Búsqueda comunitaria exige especie, rasgos, fecha/hora/punto/referencia y1–3 fotos; tipo de Otra especie, tamaño/sexo según datos disponibles, sin edad o nombre inventados. Aviso exige búsqueda abierta, tipo, descripción hasta200, fecha/hora y punto/referencia;0–3 fotos. Fecha/hora se eligen por separado. El servidor toma metadatos de la búsqueda, no de la edición del aviso. La vista previa expone zona aproximada y evita domicilio/documentos/datos personales.

## Persistencia y permisos

Caso propio en lost_cases; búsqueda comunitaria/aviso en found_cases con report_kind y un solo FK de destino. UUID/fotos estables, instantánea privada, metadatos y derivados verificados; RPC de preparación/publicación/lectura/confirmación, sin escrituras directas. Exactos y referencia privados; proyección explícita pública. Cierre solo autor; historial, contador y versión de mascota propios atómicos e idempotentes. No cambia el estado del caso por recibir un aviso. Registros anteriores permanecen legacy_found; no se les inventa padre o significado.

## Errores y reintentos

Toast superior y shake/invalid, con borrador conservado. Respuesta ambigua bloquea la misma orden hasta reintento/consulta/descarte autorizado. Destino cerrado rechaza el aviso; Ver casos abiertos relee el catálogo sin perder fotos/UUID. Aún no hay avisos solo tras consulta exitosa; error permite retry. Foto opcional no dispara un error por ausencia. Cambio de cuenta descarta resultados tardíos y desmonta datos anteriores. Consulta de listas y fotos permite recuperar fallos sin reabrir búsqueda.

## Dependencias, activación y validación pendiente

Aplicar [migración018](../../supabase/migrations/20261011001800_recovery_report_links.sql) tras001–017; requiere pipeline anterior de fotos operativo. App y SQL deben activarse juntos. UI depende de componentes compartidos de Mascotas; no importa presentación de otras funcionalidades. SQL/Flutter probados localmente; resultado final en [ESTADO](../ESTADO.md). Pendientes Supabase autenticado, carreras con conexiones independientes, Android/fotos/teselas reales. Sin despliegue/QR/web/push ni historia cerrada.

Trazabilidad: HU-05/RF-05, HU-06/RF-06; partes app de HU-10/RF-11 y confirmación de HU-13/RF-07 adelantadas por el usuario. Revisión completa de HU-11/RF-12,14 y exploración/paginación de HU-07/RF-13 permanecen pendientes.


## Selección del origen sin recarga — 11 de octubre de 2026

Mi mascota/Otra mascota alterna dentro de la misma pantalla, manteniendo selector/título y los dos borradores durante la visita. Cambio inmediato de campos, sin transición entre opciones; no navega ni repite catálogo/skeleton/cover/stagger. Skeleton solo para datos iniciales realmente pendientes. Al salir se confirma descarte de datos de ambas opciones; envío/fotos/respuesta ambigua bloquean alternar. No es persistencia offline ni edición de publicado. Composición en app y fronteras intactas; [ADR-035](../decisiones/035-alternar-origen-sin-recargar-formulario.md). Validación final en ESTADO; sin SQL nuevo.


Consulta unificada desde Inicio en [Mis reportes](mis-reportes.md): búsquedas propias/comunitarias, avisos y pendientes conservan origen/estado, ficha/eliminación/descarte y refresco al volver. Reportar queda con dos opciones de creación, sin Cerrar ni enlaces de consulta. Sin SQL nuevo; [ADR-036](../decisiones/036-reportar-y-mis-reportes.md).


## Avisos desde la ficha — 12 de octubre de 2026

Sustituye el acceso genérico anterior: Reportar abre directamente Mascota perdida. La vi o la encontré solo se ofrece en ficha de búsqueda abierta; destino fijado, sin selector de casos. ReadRecoverySearch lee una proyección concreta y no consulta catálogo. Si el destino se cierra, toast/retorno y borrador conservado hasta salir, sin reenviar o cambiar vínculo. Ruta sin vínculo/origen vuelve a Inicio. Mis reportes mantiene ambas clases de publicación. [ADR-037](../decisiones/037-avisos-desde-ficha.md). Sin SQL nuevo; Explorar sigue pendiente, no se afirma entrega de HU-07.


## Formulario único de pérdida — 12 de octubre de 2026

Sustituye las pestañas de ADR-035: Mascota a reportar permite elegir una ficha o No está en mis mascotas. Ficha muestra resumen/fotos públicas; sin ficha pide descripción/fotos sin registrarla como propia. Fecha/hora/mapa/referencia y revisión forman un solo bloque conservado al seleccionar. Cada origen mantiene descripción y fotos, UUID y permisos existentes; no se mezclan datos de mascotas ni identidades. Bloqueos, descarte, toast y vista previa conservados. [ADR-038](../decisiones/038-formulario-unico-mascota-perdida.md). Sin SQL nuevo; evidencia local y Android pendiente en ESTADO.
