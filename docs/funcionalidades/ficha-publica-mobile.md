# Ficha pública móvil por tarjetas glass

Refinamiento20/10 por corrección visual del usuario: etiqueta del caso a la derecha del nombre y centrada verticalmente en la misma fila; puntos de galería centrados debajo. Con texto ampliado o etiqueta larga se apilan y la foto crece. Tarjetas y controles de contacto usan GlassSurfaceFinish.frosted (ribete blanco único, sombra suave y tono perla/celeste traslúcido), sin doble borde oscuro ni relleno gris adicional. Volver/guardar e ImmersivePhotoSheet conservan su acabado. Renders comparados con el mockup; ver validación en ESTADO.

Incremento20/10 de HU-05/06/07, RF-05/06/13. Implementado localmente según
[ADR-113](../decisiones/113-ficha-publica-tarjetas-glass.md); no cierra historias.

## Qué hace y recorrido

Ver ficha desde Explorar, mapa, Guardados o casos propios abre el mismo detalle
existente. Perdidos y encontrados comparten CasePublicCards/CasePublicScreenShell.
Foto en galería, nombre y etiqueta, contacto autorizado, datos etiquetados y
rasgos expandibles, fecha de observación/desaparición, mapa aproximado y acciones.
Volver/guardar conservan sus controles glass, permisos y operación reales.
El título sale con el scroll; los controles permanecen flotantes y accesibles.

## Datos y acciones

Perdidos: nombre, especie, sexo/tamaño/edad si constan y rasgos disponibles.
Encontrados/avisos: especie o detalle real, sexo/tamaño/cuidado si constan, sin
inventar nombre ni edad. Etiqueta distingue posible pérdida, avistamiento,
encontrada y cierre. Sin fotos usa alternativa semántica; no muestra fotos falsas.
Mapa usa coordenadas públicas/radio1000m y señala privacidad; ninguna ciudad o
referencia exacta inventada. Conserva crédito configurado y reintento compartidos.

Seguimiento se ofrece solo con el permiso existente de cronología. CTA azul
Reportar avistamiento en búsquedas activas; después se conservan seguir/dejar de
seguir, cartel del autor, avisos/custodia, cierre y denuncia según permisos.
El contacto y sus acciones se describen en [su ficha](contacto-reportante.md).

## Persistencia, errores y dependencias

Este layout no cambia repositorios ni RPC de casos. Consume las proyecciones
actuales mediante ViewModels; contacto se compone por slot desde router.
Skeleton por tarjetas en carga inicial; refresco de la misma identidad conserva
contenido con shimmer. Error/validación/resultado van al toast; reintento real.
Cambiar identidad elimina contenido anterior según los ViewModels existentes.
Reutiliza GlassSurface, ZoneMapPicker/MapStyle, descripción, LoadingShimmer,
cover/stagger, NavigationAccentSurface, AppScaffold y controles de navegación.

## Diseño conservado y validación

[ImmersivePhotoSheet](ficha-fotografica-inmersiva.md) se conserva íntegro y sigue
en vistas previas de publicar; no es el diseño de Ver ficha actual.
Mockup aprobado en mockups/ficha-publica-glass-contacto.png, solo referencia.
Layouts390×844 y320×350/texto2, galería, descripción, mapa público y acciones
probados con movimiento normal/reducido y renders locales. Datos/fotos de los
tests son fixtures, nunca se incorporan a la UI del producto. Las teselas de
las capturas de pruebas son simuladas; no prueban red/proveedor real.
Resultados en ESTADO. Pendientes revisión física Android y activación del contacto
en Supabase mediante031; sin APK ni despliegue web/backend.
