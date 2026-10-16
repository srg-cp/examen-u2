# Entre Huellas: regla de oro de UI y UX

**Mapa, revisión del 16 octubre:** panel inferior destinado a filtros reutilizados y Aplicar filtros; al tocar un pin se reduce y aparece una etiqueta compacta con Abrir caso junto al punto. Sin ficha automática en el panel. Coincidencias se recorren dentro de la etiqueta. Borrador hasta Aplicar, CTA fijo cuando cabe y accesible por scroll en altura reducida; GPS/centro visual no buscan hasta confirmar. Aplicar recupera panel42% y conserva resultados/consulta compartidos con la lista. Mantener expansión de pantalla, retorno glass, privacidad, toast, shimmer real y movimiento reducido. [ADR-056](decisiones/056-mapa-filtros-inferiores-y-acceso-en-pin.md) sustituye estos detalles de ADR-055.

Mapa inmersivo de Explorar (16 octubre): Mapa abre `/home/explore-map` con OriginPageSource/OriginPageTransition desde la opción real, y vuelve a ella al cerrar. Mapa ocupa el viewport con retorno glass flotante e insets; ficha inferior deslizable al 14/42/90%, tirador persistente y una ficha de ancho completo. Coincidencias se recorren individualmente. Mantener consulta/lista debajo, datos públicos aproximados, feedback y movimiento reducido; no repetir entrada por gestos/selección/refresh. Sustituye la alternancia integrada Lista/Mapa de ADR-052. [ADR-055](decisiones/055-explorar-mapa-inmersivo-y-panel-deslizable.md).

Selección aplicada y recarga (16 octubre): la cápsula de Ubicación refleja lugar elegido y radio, con texto largo elidido visualmente y tooltip completo; GPS/selección manual se distinguen sin añadir etiquetas al buscador. LoadingShimmer conserva la estructura de su contenido al activar/desactivar pintura, para no reiniciar tarjetas, fotos ni estados durante refresh. Semántica de carga y bloqueo solo durante trabajo real; contenido de refresh conserva acciones.

Salida de selectores, 16 de octubre: cierre compartido en 320 ms, contracción acelerada suave y retirada superior de 8 px, fundido diferido al 22% y recuperación coordinada del blur/velo. Conservar progreso al invertir apertura y portal hasta finalizar; movimiento reducido inmediato. Véase ADR-044 actualizado. Posición de cada variante conservada.

**Variantes de selector, 16 de octubre:** `FilterExpansion` conserva `below` como variante principal (Filtrar casos). Ubicación usa `atOrigin`: panel desde el borde superior del componente, sobre la cápsula, con el mismo ancho completo y scroll disponible. Conserva blur/velo/fundido y cierre exterior/atrás/aplicar; con la animación original de escala/fundido del selector; sin transición de página desde el origen. Etiquetas centradas con espacios laterales equilibrados, incluso sin icono inicial. Esta instrucción sustituye el anclaje inferior de Ubicación de ADR-044/045; Filtrar casos conserva su transición.

Explorar/Ubicación,16 de octubre: por instrucción del usuario, el panel normal contiene únicamente Ubicación de búsqueda, Usar mi ubicación actual, Ciudad o dirección y sus sugerencias, Radio y deslizador, mapa y Aplicar ubicación. Sin línea Centro ni explicación adicional del mapa. No insertar etiquetas sintéticas de ubicación en el buscador: elegir un punto manual deja el campo vacío y conserva las coordenadas internas; una ciudad elegida conserva su etiqueta real. Errores/reintentos siguen el feedback compartido.

Instrucción explícita del usuario16 de octubre: retirar las menciones visibles del proveedor cartográfico, incluidos créditos, enlaces y mensajes asociados, en toda la app. Sustituye la indicación anterior de atribución visible del mapa y del buscador; conservar selección, filtros, teselas y recuperación. No volver a introducir estos elementos al intervenir mapas o buscadores. [ADR-054](decisiones/054-retirar-menciones-visibles-proveedor-mapas.md).

Explorar,16 de octubre: Lista/Mapa mediante TwoOptionFilter compartido debajo de los filtros; cambio discreto con cover→stagger, cabecera/filtros persistentes y movimiento reducido. No repetir entrada por pan/zoom, selección de punto, refresh o paginación. Mapa muestra coordenadas públicas aproximadas y agrupa coincidencias; selección presenta PublicCaseGrid para abrir las fichas existentes. Radio y centro se editan en Ubicación; el gesto de mapa solo mueve cámara. Error de teselas en toast con Reintentar mapa. [ADR-052](decisiones/052-explorar-mapa-de-resultados.md).

Corrección de recarga16 de octubre: PullToRefresh usa Stack sin recorte para que el indicador glass que entra desde coordenadas negativas no quede cortado durante el descenso/retirada. En Home envuelve toda la composición, incluida LiquidNavigation, y pinta el indicador al final sobre cabecera/contenido/acciones. Sin cambiar gesto, material o tiempos. Formato y análisis estático sin incidencias; sin pruebas/renders/build por instrucción vigente, revisión visual Android pendiente.

Ajuste vigente del16 de octubre: el marcador compacto de Explorar abre la pantalla independiente Guardados en /home/saved-cases. Reutiliza OriginPageSource/OriginPageTransition mediante entityEditorPage: expansión desde el icono y retorno al origen al cerrar, con movimiento reducido respetado. Sustituye el cambio de vista en la cabecera y la segunda pulsación. SavedCasesScreen reutiliza EntityScreenShell con retorno glass y cover→stagger, SavedCasesSection y PullToRefresh; scroll siempre desplazable incluso con lista vacía. Explorar permanece debajo con filtros/posición conservados. Sin cambios SQL;021 sigue pendiente de aplicación y revisión Android.

**Guardados y Ciudad —16 de octubre:** Explorar abre Guardados con un marcador compacto junto al título, sin selector de secciones. Marcador vacío/lleno según vista y segunda pulsación para volver; cabecera persistente y cover→stagger al cambiar vista; cada lista conserva actualización/paginación y grilla compartida. Perfil reutiliza autocompletado de Ubicación en modo ciudad, seleccionando sugerencia antes de guardar texto nuevo; vacío/valor antiguo sin editar permitidos. Mantener debounce/semántica/toast/shimmer y estados independientes por modo. Router compone slots, sin importar presentaciones entre funcionalidades. [ADR-051](decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

**Superficie de recarga por gesto —16 de octubre:** por petición del usuario, usar el mismo GlassSurface del retorno: círculo52/radio26 e icono28, conservando material/desenfoque/ribete/sombra compartidos. Sin superficie gris propia ni botón visible permanente; mantiene seguimiento/giro/retirada y movimiento reducido de ADR-049.

**Guardar casos —16 de octubre:** marcador glass flotante superior derecho en fichas disponibles, simétrico al retorno y fuera del scroll. Reutilizar GlassNavigationButton52 con bookmark vacío/lleno confirmado, tooltip/semántica y LoadingShimmer real. Toast/reintento; sin éxito optimista ni repetir entrada del contenido. [ADR-050](decisiones/050-casos-guardados-por-cuenta.md).

**Fila de controles de Explorar — 16 de octubre de 2026:** por instrucción del usuario, Ubicación a la izquierda y Filtrar casos a la derecha en una sola fila, sin apilarlos. Cápsulas compactas con fuente/área táctil conservadas; icono inicial omitido con poco ancho/texto ampliado para priorizar etiqueta completa, altura adaptable compartida. Ambos editores usan ancho completo, con anclajes izquierdo/derecho respectivamente. Sustituye la disposición adaptable a dos filas de ADR-045; no cambia la transición ni funcionalidad.

**Actualizar por gesto:** Explorar, Mis mascotas y Ubicaciones de interés se refrescan al jalar desde el borde superior y soltar, sin icono/botón ordinario de refresco. PullToRefresh conserva reconocimiento nativo sin su spinner y muestra Icons.refresh_rounded: acompaña el descenso, se acomoda al soltar, gira durante trabajo real y se retrae/desvanece al terminar/cancelar. El usuario autoriza expresamente este giro del icono de recarga; sin anillos/barras de progreso ni texto visible de carga. Contenido conservado con shimmer. Movimiento reducido sin giro/retorno autónomo, acción accesible Actualizar contenido y listas cortas/vacías admitidas. No capturar formularios ni scroll anidado; reintentos conservados. [ADR-049](decisiones/049-indicador-recarga-y-retorno.md) sustituye la flecha inicial de [ADR-048](decisiones/048-actualizar-listas-al-jalar.md).

**Ubicación inicial y terminología vigentes:** por petición del usuario, Explorar usa ubicación actual/radio15km y exige centro/radio para consultar. Sin ubicación disponible se permite selección manual y reintento, sin consulta global ni falso vacío. Control Ubicación, sin Todas las ubicaciones; otra ciudad/dirección/mapa y radio1–50km. Toda etiqueta/mensaje visible Zona/Zonas pasa a Ubicación/Ubicaciones. Contratos internos conservados. [ADR-047](decisiones/047-ubicacion-actual-y-radio-inicial.md) sustituye los detalles anteriores de valores iniciales y ausencia de GPS.

**Sugerencias de Zona:** ciudad/dirección consulta tras600ms sin edición y desde3 caracteres, sin botón Buscar ubicación ni bloqueo del campo durante consulta. Skeleton/shimmer, selección explícita de resultado y descarte de respuestas antiguas; búsqueda no aplica filtros. [ADR-046](decisiones/046-sugerencias-automaticas-de-ubicacion.md) sustituye las notas anteriores de búsqueda por botón.

**Distribución vigente de Explorar:** por petición del usuario, separar Filtrar casos (tipo/especie/estado/fecha) de Zona (ciudad/dirección/mapa/radio). Dos cápsulas en fila o vertical según ancho y texto, con paneles de ancho completo y el mismo efecto de ADR-044. Aplicar un control conserva la selección del otro. [ADR-045](decisiones/045-explorar-zona-independiente.md) sustituye la distribución unificada anterior.

**Foco y movimiento del desplegable de filtros:** por instrucción explícita del usuario, usar una transición inspirada en Control Center de iPhone: blur progresivo hasta sigma16, velo negro hasta28% y expansión/fundido sincronizados del panel desde arriba, apertura420ms/cierre280ms. El selector real queda fuera del recorte de blur/velo y permanece nítido. Sin cover ni stagger en este desplegable; es una excepción explícita, no un cambio global de entradas de pantalla. Movimiento reducido directo, cierre exterior conservado y portal presente hasta finalizar salida. Aproximación visual Flutter descrita en [ADR-044](decisiones/044-filtros-transicion-control-center.md), que sustituye este detalle de ADR-043.

**Ajuste vigente de Explorar — 15 de octubre de 2026:** Filtrar casos despliega un editor anclado al borde inferior de la cápsula, sobre la grilla y sin desplazarla; mismo ancho y scroll propio. Conserva cápsulas compartidas, sin ventana centrada. Cards con un solo badge de estado, nombre y distancia aproximada desde la zona elegida, sin especie/fecha/tipo. Si no hay distancia real se omite. [ADR-043](decisiones/043-explorar-desplegable-anclado-y-distancia.md) sustituye los detalles contradictorios de las notas anteriores de ADR-040–042.

**Regla vigente — 11 de octubre de 2026:** feedback de errores, validación y resultados en el toast superior compartido en todas las funcionalidades. Sin texto bajo inputs, errorText/helperText ni indicadores circulares/lineales. Skeleton y LoadingShimmer para carga inicial/acciones; ContentRefresh con shimmer conserva contenido durante refresh. Se mantienen invalid/ShakeField, semántica, reintentos, etiquetas/datos e instrucciones de privacidad. [ADR-027](decisiones/027-feedback-global-toast-shimmer.md) sustituye las restricciones anteriores de feedback; las notas fechadas anteriores son historia de las decisiones.

Estado: **norma obligatoria**. Aprobación de la dirección visual por el usuario: 8 de octubre de 2026. Plataforma de referencia: aplicación móvil Flutter, Android primero.

## 1. Regla principal y autoridad

**Cada pantalla debe sentirse parte de la misma aplicación que Iniciar sesión, Crear cuenta, Recuperar contraseña, Revisa tu correo, Nueva contraseña y Contraseña actualizada. Se reutilizan su lenguaje visual, geometría, componentes, estados y secuencia de interacción.**

Estas pantallas implementadas son la referencia aprobada. La paleta de UI del mockup `mockups/Entre Huellas_ personajes 3D premium.png` es la referencia cromática aprobada el 9 de octubre de 2026; las pantallas actuales conservan la referencia de geometría e interacción. Las instrucciones explícitas del usuario prevalecen sobre esta norma. Una propuesta diferente debe presentarse como un cambio deliberado de diseño y actualizar este documento; no introducir otra identidad por comodidad del framework.

Esta norma sustituye la dirección antigua de superficies coloreadas, tarjetas grandes y botones tipo píldora como estilo general. El antiguo Inicio con AppBar y «Tu comunidad» queda retirado y no es referencia. Inicio incorpora la composición de navegación liquid glass aprobada el 8 de octubre y descrita al final de esta norma; los módulos de producto pendientes conservan su disponibilidad explícita.

Leer esta norma antes de cualquier cambio visual junto con [las reglas de arquitectura](REGLAS_ARQUITECTURA.md), [estado](ESTADO.md) y el sprint de [la guía](GUIA_MVP.md). [DISENO_UI.md](DISENO_UI.md) localiza implementación y revisión. [ADR-005](decisiones/005-feedback-sin-snackbar.md) y [ADR-006](decisiones/006-transiciones-y-carga-con-shimmer.md) complementan feedback y movimiento.

## 2. Identidad y composición

- Fondo blanco, composición limpia, espacio suficiente y una jerarquía clara. La paleta de UI se limita a blanco #FFFFFF, negro #111111, superficie #F5F5F7, texto secundario #6E6E73 y separadores #E5E5EA. El tema Material, los estados de selección, foco y pulsación también usan estos neutros, sin semillas cromáticas ni tintes. Se conserva el rojo contextual de error de ADR-005.
- Icono y nombre forman una sola identidad. Reutilizar BrandMark/BrandWordmark y `assets/branding/app_icon.png`; no sustituirlos por otra huella, texto o icono de Material. Conservar proporción y esquinas del asset.
- Marca, título y campos de formularios se alinean al margen izquierdo. Centrar los elementos de confirmación que ya lo requieren: mascota, título de correo, explicación, OTP y reenvío.
- No añadir una AppBar genérica, navegación inferior, tarjetas decorativas, sombras, gradientes o menús solo para llenar la pantalla. Un módulo con contenido real puede necesitar otra composición, pero conserva estos tokens y componentes. No exigir el gran encabezado del login en cada fila o pantalla de contenido.
- Cada pantalla expresa una tarea principal. Acciones secundarias quedan subordinadas y tienen comportamiento real. No añadir funcionalidades futuras, datos simulados, enlaces legales sin documentos ni controles sin acción.

## 3. Colores y tipografía

| Uso | Valor aprobado |
| --- | --- |
| Fondo de pantalla, splash y espera | `#FFFFFF` |
| Marca textual y títulos | `#111111` |
| Texto secundario e indicaciones | `#6E6E73` |
| Acción principal | Fondo `#111111`, texto blanco |
| Fondo de campos | `#F5F5F7` |
| Bordes normales / divisores de acceso | `#E5E5EA` |
| Borde de campo enfocado | `#6E6E73`, ancho 1.5 |
| Iconos de campo normales | `#6E6E73` |
| Error contextual | `#B53F48` |

Usar sans serif del sistema (`AppTheme.fontFamily`), sin incorporar otra familia por pantalla. Títulos de formulario: 48, peso/altura/espaciado del tema aprobado; no reducirlos silenciosamente para forzar un layout. Marca de cabecera: icono 80 y texto 32 con peso 800, dos líneas, interlineado .95 y separación 12. Título de Revisa tu correo: 32, peso 700. Explicaciones generales: 18; indicación OTP: 16, interlineado 1.4. En «Ingresa el código que llegó a {correo}», solo el correo es negro; frase, puntuación y duración usan gris secundario. Texto de campos: 16 con altura de línea 27; acción principal: 18, peso 600. Ayuda/reenvío: 16; pie de login: 15; error de campo: 13, ampliable.

Estos tamaños son lógicos de Flutter y respetan el escalado del sistema. En módulos nuevos, construir jerarquías a partir de ellos y del tema; una fila de contenido no necesita un título de 48. Mantener contraste, texto legible y etiquetas comprensibles.

## 4. Dimensiones y componentes

| Elemento | Geometría / regla |
| --- | --- |
| Layout de acceso y base compartida | SafeArea, scroll, ancho máximo 440, margen horizontal 24 |
| Anclaje vertical de formularios | `max(28, (alto disponible − 660) / 2)`; conservar cabecera al cambiar etapa |
| Marca → título / título → campos | 14 / 20 |
| Campo | Radio 22, padding vertical 22 y horizontal 16, icono 22, borde normal 1 |
| Acción principal | Ancho disponible, alto mínimo 60, radio 24, padding vertical 18 y horizontal 24 |
| Google | Alto mínimo 56, icono 20, texto 15, espacio 8, padding vertical 13 y horizontal 22 |
| Cierre de formulario | X de 30, margen izquierdo 16 en el contenedor, área táctil de IconButton |
| Mascota de correo | Caja 320 × 320, `BoxFit.contain`, sin recortar; espacio inferior 8 |
| Explicación de correo → OTP | 28 |

Los mínimos no son alturas rígidas: permitir que crezca el texto. Las imágenes se ajustan al ancho disponible; los controles quedan accesibles por scroll. No corregir desbordamientos comprimiendo la fuente ni ocultando acciones.

AppPageLayout y primaryActionButtonStyle están en `core/presentation/widgets` para reutilizarse fuera de Auth. AuthPageLayout/authPrimaryButtonStyle conservan nombres compatibles y delegan en esos componentes. BrandMark, BrandWordmark, CoverReveal, AuthStageTransition, StaggerReveal, StaggerRevealItem, LoadingShimmer y ShakeField son implementaciones únicas compartidas. El nombre AuthStageTransition no autoriza a copiar su lógica para otros módulos.

Un componente específico de Auth, como EmailCodeConfirmation o authInputDecoration, se reutiliza dentro de esa funcionalidad. Si otra funcionalidad necesita exactamente la misma responsabilidad visual, extraerla a core y mantener compatibilidad; no importar la presentación de Auth desde otro módulo. Pantallas componen widgets; ViewModels/casos de uso siguen controlando operaciones y reglas.

## 5. Movimiento: orden obligatorio

**Cambio discreto de pantalla o etapa: cover reveal completo → stagger reveal del destino.** No ejecutar ambos al mismo tiempo. Mantener la marca/cabecera fuera del efecto al pasar entre etapas de un mismo flujo.

| Efecto | Parámetros y uso |
| --- | --- |
| CoverReveal | Cortina blanca plana vertical de 320 ms, `easeInOutCubic`; sin escala ni radios animados en cambios internos |
| StaggerReveal | Una línea de tiempo por entrada/etapa; 850 ms por elemento, desfase 90 ms, blur inicial 18, desplazamiento inicial Y −28, `Cubic(.22, 1, .36, 1)` |
| Duración total de stagger | `850 + (cantidad de intervalos − 1) × 90` ms; usar orden de lectura y bloques reconocibles, no animar cada carácter |
| Apertura existente de registro/recuperación | OriginPageTransition desde el control real: 320 ms; cierre 260 ms. Conservar solo esta entrada de ruta aprobada |
| Cambios correo → código → nueva contraseña → éxito | Cover plano y después stagger; conservar cabecera; nunca expansión desde el botón |
| Arranque Flutter | 1100 ms: icono centrado de 96, logo hacia izquierda y nombre emerge detrás hacia derecha; `easeOutBack`, leve sobrepaso y retorno exclusivamente horizontales |

La excepción de resorte horizontal pertenece al logo y nombre del arranque: no agregarles movimiento arriba/abajo. El stagger de los demás componentes conserva su desplazamiento vertical aprobado. La animación del arranque termina antes de montar el destino; el login completa cover y después empieza stagger. No sumar un fundido de ruta que oculte esta secuencia.

No repetir entradas al editar, abrir/cerrar teclado, alternar visibilidad de contraseña, actualizar contador, reenviar dentro de la misma etapa o mostrar error de campo. No bloquear un error contextual esperando una nueva cascada. Un resultado como Contraseña actualizada sí constituye otra etapa. Conservar controles/estado anteriores durante la cortina y bloquear interacción y semántica del contenido saliente.

No animar todo en cada frame. El PageView del onboarding conserva su gesto continuo y reveal textual existente; su comportamiento por cuenta no cambia. En pantallas de listas o contenido futuro, elegir entradas discretas que expliquen el cambio, no volver a revelar toda la pantalla por cada actualización.

## 6. Carga, deshabilitación y errores

- Durante una operación real, mantener texto, dimensiones y posición del botón. LoadingShimmer barre desde el borde inicial, dura 1400 ms por ciclo y respeta el radio. Cada operación nueva reinicia la fase; reconstrucciones de la misma operación la conservan.
- Atenuar el contenido a opacidad .72 y pintar el brillo encima. Bloquear dobles envíos. Terminar y liberar el efecto al resolver la operación o desmontar el widget.
- Nunca cambiar el botón a «Enviando…», «Guardando...» o equivalentes con puntos suspensivos; nunca sustituir su texto por spinner. La semántica comunica el progreso con una etiqueta breve, estado deshabilitado y liveRegion, sin anuncios por frame.
- Un botón deshabilitado por validación o cooldown no está cargando: no mostrar shimmer. En OTP, distinguir verificación y reenvío para iluminar solo la acción activa.
- Errores de campo: borde rojo de 3.5, texto/icono del campo en rojo, fondo normal, explicación en toast superior y ShakeField de 360 ms; sacudida horizontal amortiguada, amplitud inicial 4. Repetir solo ante un error nuevo. Edición permite recuperarse sin perder datos válidos.
- Fallos generales y resultados se muestran en el toast superior, con mensajes breves y acciones reales. No propagar mensajes técnicos/tokens del SDK.
- Nunca usar SnackBar ni barra inferior equivalente. ADR-007 permite confirmación de éxito mediante toast superior propio por instrucción del usuario; ADR-027 extiende el toast a errores y validación. Mantener comprobación automática y limpieza de overlay/timer al salir.

## 7. Flujos y textos de referencia

Login conserva marca, Iniciar sesión, correo, contraseña, recuperación, Ingresar, Google y Crear cuenta. Sin subtítulo, avisos de configuración/sesión o Apple. Registro conserva cuatro campos y X; sin añadir pie de retorno ni casilla legal pendiente.

Recuperación solicita correo con Enviar código. Revisa tu correo muestra mascota, indicación breve con correo real, duración confirmada si está configurada, seis casillas y reenvío tras 60 segundos. No muestra Volver a iniciar sesión; la X permite salir. No afirmar existencia de cuenta.

OTP permite teclado numérico, pegado/autofill, ceros iniciales y retroceso. Un único campo real controla seis casillas visuales; verificar automáticamente al sexto dígito y permitir reintento explícito tras fallo. No inventar códigos ni éxito local. La sesión válida decide el acceso. La duración se muestra solo con configuración confirmada; no inferirla desde el mockup.

Nueva contraseña conserva campos y visibilidad independiente, feedback en toast superior; Guardar contraseña conduce a Contraseña actualizada con cover/stagger. Mantener cierre de sesión de recuperación al salir. Una cuenta autenticada con onboarding pendiente conserva sus tres etapas y guardado por cuenta; no introducir Omitir ni saltarlo al cambiar diseño.

## 8. Accesibilidad y contenido adaptable

- Respetar SafeArea, teclado, botón Atrás y rutas de cierre durante operaciones. Conservar contenido y estados reales.
- Revisar al menos 390 × 844 y 320 × 350 con texto a escala 2; pantallas nuevas incluyen sus estados vacío/carga/error/datos reales y acciones inferiores alcanzables.
- Movimiento reducido: destino inmediato, shimmer estático, sin resorte, blur, shake ni expansión. No forzar animaciones si el usuario las desactivó.
- Semántica continua para marca/texto; ilustraciones decorativas excluidas. Etiquetar iconos interactivos; no depender solo del color. No reducir áreas táctiles al tamaño del icono.
- Evitar clip del texto o ilustración como solución de layout. El recorte de revelación es temporal; al terminar se ve el elemento completo.

## 9. Criterio de aceptación visual

Un incremento visual está completo cuando:

1. Conserva la dirección de las pantallas aprobadas y reutiliza componentes; cualquier cambio de lenguaje tiene aprobación explícita y documentación actualizada.
2. Implementa estados reales, recuperación tras error y acciones disponibles; no añade pantallas ficticias ni pierde reglas de sesión.
3. Verifica secuencia cover → stagger, ausencia de reinicios innecesarios y carga con shimmer desde el inicio.
4. Pasa formato/análisis y pruebas significativas de flujo/estado/arquitectura pertinentes; no añade tests que solo repiten cada constante estética.
5. Se revisan capturas renderizadas normales/pequeñas y texto ampliado. En animaciones se revisan fases y orden, no solo imagen final.
6. ESTADO registra qué se comprobó, qué falta y el siguiente paso. Renders con repositorios sustituidos no demuestran SMTP/Auth remoto ni rendimiento de dispositivo.

Desde la app: `flutter test --no-pub tool/capture_ui_preview.dart` genera revisión en `build/ui-preview`. Cambios Flutter de arranque necesitan Hot Restart; recursos del splash Android necesitan build e instalación nuevos. La máscara nativa del splash se valida en arranque frío en dispositivo; AAPT2 por sí solo no demuestra su aspecto.

## 10. Evolución de la norma

Para una nueva pantalla, partir de estas reglas y de una operación/HU real. Definir composición, estados y componentes que se reutilizarán, implementar, renderizar y verificar. Registrar ajustes aprobados en esta norma y en DISENO_UI/ESTADO. Si alteran una decisión de movimiento/feedback o fronteras de arquitectura, actualizar la decisión versionada correspondiente. No convertir un boceto provisional o una pantalla heredada en una nueva regla de oro.

## Inicio y navegación aprobados, 8 de octubre de 2026

Por instrucción del usuario se incorpora una cápsula flotante de navegación con acabado liquid glass y botón circular separado con nueve puntos 3 × 3 para Reportar. El botón es sólido #111111, igual que el indicador activo, sin glass y con puntos blancos. Es una composición específica de Inicio, no un cambio de la identidad de acceso: fondo blanco, tipografía del tema y paleta neutra de acceso. La superficie usa blur limitado a su contorno, borde claro, reflejo mediante gradiente suave y sombra ligera; no se generalizan estos efectos a formularios o tarjetas.

Destinos principales: Inicio, Explorar y Mis mascotas. Perfil se abre desde el avatar superior. Por ajuste explícito del usuario, la cápsula muestra solo iconos en todos los tamaños, con tooltip, nombres accesibles y semántica selected. El indicador único de selección se desliza horizontalmente desde su posición actual hacia el destino en 320 ms con easeInOutCubic; acepta cambio de destino durante el recorrido y respeta movimiento reducido con cambio inmediato. Los iconos ajustan su contraste según el paso del indicador. Este efecto local no reinicia ni sustituye cover/stagger del contenido. La selección usa carbón #111111 e icono blanco; los iconos inactivos usan #6E6E73. El cristal usa mayor transparencia, blur localizado de 22 y doble borde de reflejo neutro, con colores de la paleta aprobada. Reportar abre un panel con los dos tipos de reporte. En este incremento los módulos de casos/mascotas/alertas siguen pendientes: no se muestran registros ficticios, ausencia de casos supuestamente consultados ni controles de publicación activos. Perfil conserva salida real. Cabecera fuera de cover/stagger y scroll completo para superficies pequeñas; la cápsula permanece accesible sobre el contenido con margen inferior de scroll.

La selección de destinos no usa splash ni overlay de pulsación/hover de Material: el feedback visual es el indicador carbón deslizante, sin destello claro superpuesto, por corrección explícita del usuario.

Cabecera de Inicio simplificada por ajuste del usuario: reutilizar BrandWordmark compacto (icono 46, texto 22), con «Entre» y «Huellas» en dos líneas, sin «Unidos para volver a casa». Se conserva la marca original y el acceso de alertas; no se repite la cabecera grande de login.

Perfil simplificado por corrección del usuario: un único título «Perfil», campos «Nombre» y «Ciudad», sin «Tu cuenta», «Tu información» ni explicación permanente del límite. La validación se mantiene y el límite se comunica junto al campo ante error. Cerrar sesión es una acción secundaria danger suave: fondo #F9ECEE, texto #B53F48, fuente 14/peso 600, padding 16 horizontal/10 vertical, alto mínimo 48 y radio 18; crece con texto ampliado, conserva área táctil y LoadingShimmer al salir. El botón principal Guardar cambios conserva su estilo carbón.

## Confirmación superior de éxito

[ADR-007](decisiones/007-confirmacion-toast-superior.md) registra el cambio solicitado por el usuario. Perfil usa ConfirmationToastHost de core: «Cambios guardados», carbón, icono de éxito, cierre accesible, duración 3 s (6 con accessibleNavigation), entrada local 180 ms y movimiento reducido. Sustituye el texto de éxito bajo el botón y no altera el layout. Errores se conservan junto al campo/acción. El aviso pertenece a la pantalla y se limpia al editar, desmontar o cambiar identidad; solo se muestra una vez por confirmación nueva, no al montar datos ya guardados. No generalizar automáticamente a Auth ni a resultados que necesitan otra acción.

Ajuste del toast solicitado por el usuario: estética iOS con cápsula de ancho ajustado al contenido, cristal claro #F5F5F7 translúcido, blur localizado 18, borde blanco/sombra suave e icono/texto carbón. Sin X; tocar el aviso lo cierra, con hint/acción semántica de dismiss. Alto mínimo 48 y radio 28, ampliable sin truncar texto. Mantiene duración, posicionamiento superior, limpieza por pantalla y entrada con movimiento reducido de ADR-007.

## Perfil desde avatar y navegación principal, 8 de octubre de 2026

Por aprobación explícita del usuario, Inicio conserva BrandWordmark a la izquierda, campana y avatar a la derecha. Perfil se retira de la cápsula: quedan Inicio/Explorar/Mis mascotas, además de Reportar con nueve puntos. El indicador deslizante adapta sus tres posiciones y dirección del texto.

Tocar avatar abre Perfil como ruta superpuesta mediante OriginPageTransition desde sus límites reales (320 ms, cierre 260 ms). Tras completar expansión comienza el stagger del contenido; no se añade otra cortina. Cerrar con X/Atrás conserva la sección y scroll de Inicio. Movimiento reducido inmediato. Perfil muestra avatar mayor, campos existentes, salida danger suave y toast de confirmación; no lleva barra inferior.

Avatar muestra primero la foto privada subida por la cuenta y usa como respaldo una foto HTTPS disponible en sus metadatos (avatar_url/picture, por ejemplo Google), proyectada por fuente/DTO/repo. Sin foto o ante fallo usa iniciales del nombre persistido; sin nombre un icono neutro. No simular personas ni exponer metadatos completos. La selección desde galería se incorpora por solicitud posterior del usuario mediante ADR-008, con permisos propios de almacenamiento.

Perfil ofrece el avatar como único control habitual para cambiar foto, con distintivo de cámara y etiqueta accesible, sin Añadir/Cambiar foto debajo. LoadingShimmer cubre el avatar durante selección/subida; cancelar no envía. Por solicitud explícita y ADR-009, los errores de foto usan el toast superior existente con icono de error; tocar nuevamente el avatar reintenta los bytes retenidos o abre galería si no hay imagen válida. Las selecciones recuperadas requieren confirmación explícita. El correo de Auth se muestra seleccionable y de solo lectura; solo nombre y ciudad son campos editables. El toast de éxito aparece después de confirmación remota, sin sobrescribir borradores. Mantener scroll y controles accesibles con texto ampliado.

Inicio ya no muestra «Cada huella cuenta» ni «Ayudemos a que vuelvan a casa», por corrección del usuario: el contenido empieza después de la cabecera sin ese bloque promocional. Reordenados intervalos de stagger según los tres bloques restantes; no se altera onboarding.

## Mascotas propias, Sprint 2

La dirección visual aprobada de acceso se aplica a Mis mascotas, Registrar mascota, Ficha de mascota y Editar mascota: fondo blanco, carbón y superficies neutras, inputs compartidos/radio 22, acción principal existente, LoadingShimmer durante guardado y ShakeField ante error nuevo. No agregar slogan, datos simulados, acciones vacías o selector de fotos aún no implementado. Cabecera de pantalla persistente; cover seguido de stagger para carga/error/formulario discretos, sin reinicio por texto/teclado o guardado.

Nombre y especie obligatorios; sexo, edad aproximada en meses y rasgos admiten desconocidos. Límites se comunican ante error junto al campo; errores de red/conflicto junto a guardar con borrador preservado. Ver ficha actual permite consultar sin sobrescribir la edición pendiente. Mis mascotas muestra vacío solo tras consulta exitosa. Selección con texto ampliado y controles alcanzables por scroll. Confirmación de mascota con toast existente después de persistencia real, ligada a dueño y pantalla. Véase ADR-010.

## Selectores propios en formularios, 9 de octubre de 2026

Por ajuste explícito del usuario, Especie y Sexo de mascotas sustituyen DropdownButtonFormField por AppSelectField compartido de core. El campo reutiliza appInputDecoration, radio 22, padding, iconos y tipografía de los inputs; no usa menú rectangular nativo. Flecha con giro local de 180 ms al abrir/cerrar, inmediato con movimiento reducido; foco/error comparten bordes existentes. El valor se controla desde ViewModel y el control se deshabilita durante guardado.

Al tocar se cierra el teclado y abre panel inferior blanco con esquinas superiores de 28, cabecera persistente y cierre accesible. Opciones en superficies neutras/radio 18, selección carbón con icono/check blanco y semántica selected; área mínima 60 y altura adaptable al texto. Cover/stagger solo al entrar en opciones, sin reinicios por gesto/selección; panel desplazable en superficie pequeña. Conserva escala de texto/movimiento reducido del campo. Cerrar/Atrás cancela sin modificar valor; No lo sé es una elección válida de sexo, distinta de cancelar.

## Carga de contenido sin texto visible

Por instrucción explícita del usuario y ADR-011, no mostrar Cargando/Preparando como texto de progreso ni usar indicador circular en la UI. Primera consulta: skeleton del contenido esperado, sin datos ficticios, con LoadingShimmer compartido y geometría adaptable al texto. Durante refresh explícito con datos de la misma cuenta: conservarlos y superponer línea fina de progreso sin desplazar el layout. Movimiento reducido deja placeholders estáticos y pausa el progreso indeterminado; labels de accesibilidad siguen informando el trabajo.

Aplicado a mascotas (listado, ficha, editor) y Perfil. Cabecera/navegación preservadas; error contextual con reintento, vacío solo después de consulta exitosa. Cambios de cuenta/dependencia ocultan datos anteriores, incluso durante refresh. Guardado conserva etiqueta real y shimmer del botón de ADR-006. No usar retrasos artificiales para exhibir el skeleton. Mantener comprobación automática de esta regla.

## Campos con etiqueta interior, 9 de octubre de 2026

Por solicitud explícita del usuario, los nuevos campos de texto y selección comparten una etiqueta persistente dentro del borde, alineada arriba; el contenido editable o seleccionado aparece debajo. No duplicar la etiqueta encima del campo. Referencias de comportamiento: las dos imágenes aportadas en el chat (Nombre/Descripción vacíos y con contenido); los colores siguen la paleta clara del mockup, no el fondo oscuro de esas referencias.

AppTextField y AppSelectField usan AppFieldSurface en core. Icono izquierdo opcional: al omitirlo, etiqueta y contenido aprovechan el ancho desde el padding interior. Radio 22, padding 16, etiqueta 13/altura 1.3 y contenido 16/altura 27; crecen con texto ampliado. Etiqueta siempre dentro del borde, también al enfocar/vaciar; sin label de Material sobre la línea superior. Texto multilínea admite altura mínima y crecimiento; pistas opcionales de texto solo al enfocar. Error contextual exterior y ShakeField conservados; foco neutro, deshabilitación durante trabajo real y semántica con nombre del campo. No repetir cover/stagger por edición o foco.

Integrado en registro/edición de mascotas y Perfil, incluido correo seleccionable de solo lectura. Tamaño y fotos conservan sus controles propios. Los formularios de acceso conservan sus componentes actuales; los nuevos formularios usan los componentes compartidos con etiqueta interior. SkeletonFormFields refleja la geometría del marco completo sin etiqueta externa.

## Una sola entrada durante carga de contenido

Corrección autorizada el 9 de octubre: la respuesta que sustituye un skeleton (datos, vacío confirmado o error) aparece directamente, sin segunda secuencia cover/stagger. El cambio de estado de consulta no es un cambio de pantalla/etapa. Si llega durante el stagger, el resultado se muestra completo inmediatamente; las cargas con skeleton omiten cortina y stagger desde el primer frame, según el ajuste de continuidad posterior. Una navegación real conserva su entrada; reintentar/refrescar o cambiar identidad dentro de la pantalla no repite efectos y mantiene aislamiento de datos. Véanse ADR-006 y ADR-011 actualizados.

### Continuidad de carga: excepción de entrada aprobada

Por corrección posterior del usuario, el skeleton se muestra estable desde el primer frame, sin cover ni stagger que vuelvan a ocultarlo. Mantener únicamente el shimmer durante la espera y la transición de ruta; no añadir demoras artificiales. Mis mascotas omite los efectos de sección del Home. Ficha/editor esperan metadatos y fotos en una sola carga visual, sin montar otra consulta de galería al presentar el contenido. Perfil también evita stagger sobre su skeleton. Acceso y contenido disponible desde el inicio conservan sus efectos. Esta instrucción sustituye la posibilidad anterior de terminar una cortina sobre el skeleton; ADR-006/011 actualizados.

## Registrar mascota: expansión desde el botón

Ajuste aprobado el 9 de octubre: Registrar mascota abre su formulario con OriginPageTransition, como Crear cuenta. Capturar el rectángulo real del FilledButton (no solo del texto) relativo al Navigator, incluidos scroll y texto ampliado. Apertura 320 ms, cierre 260 ms, inmediato con movimiento reducido. Volver contrae al origen y conserva Mis mascotas. No sumar cortina ni stagger sobre carga; no cambiar validación, fotos o guardado.

## Confirmación y error de eliminación de mascotas

Corrección explícita del usuario, 9 de octubre: Cancelar y Eliminar mascota tienen igual tamaño intermedio, mismo ancho, altura mínima 48, fuente 14/peso 600, radio 18 y padding 8. Se distribuyen en fila si las etiquetas caben; con texto ampliado se apilan con ancho/alto iguales, sin recorte. Se conservan borde neutro y danger suave para distinguir las acciones.

ADR-013 permite el toast superior existente para errores de eliminación. Retirar el texto de error debajo de tarjetas; informar reintento al deslizar en el aviso. Conflicto conserva Actualizar lista dentro del toast. Avisos nuevos se identifican por resultado para repetir errores consecutivos; limpieza al abandonar pantalla/cambiar identidad, expiración y accesibilidad conservadas. La confirmación de éxito sigue dependiendo del servidor y los demás errores mantienen ADR-005.

Ajuste posterior de confirmación: reducir padding de ambas acciones a 8 por lado, separación 8 y mínimo táctil 48. Conservar ancho/alto iguales, ajustados a la etiqueta más larga en lugar de ocupar todo el ancho. Grupo alineado abajo a la derecha; si deben apilarse por texto ampliado, conservar alineación derecha y altura común sin truncar.

## Mis mascotas: registro según estado del listado

Ajuste aprobado el 9 de octubre: vacío confirmado muestra huella neutra de88, título/mensaje existentes y Registrar mascota debajo del bloque, centrado y con ancho ajustado al contenido (máximo280). Se retira la acción ancha encima del vacío/listado. Con mascotas confirmadas, cabecera muestra + Mascota compacto en esquina derecha, superficie #F5F5F7, icono/texto #111111, fuente14/peso600, mínimo táctil48 y radio18. Con texto ampliado/poco ancho, acción sigue a la derecha en su propia línea, sin reducir fuente ni recortar.

Ambas variantes utilizan PetRegistrationButton con etiqueta accesible Registrar mascota y OriginPageTransition desde sus límites reales. Vacío solo tras consulta satisfactoria; skeleton/error no simulan ausencia ni muestran la invitación de vacío. Refresh conserva acción/listado de la misma cuenta. No se introducen datos ficticios ni otro estilo de navegación.

## Deslizar mascota y confirmar al soltar

Ajuste autorizado y corrección posterior: la tarjeta puede desplazarse hacia la izquierda hasta70% de su ancho, sin quedar detenida mostrando un botón Eliminar. Rojo progresivo sobre la tarjeta y contraste de texto/iconos durante arrastre. Al soltar tras recorrido suficiente, retornar a la posición original y después abrir confirmación. Deslizamiento corto, hacia derecha o cancelación no solicita borrar. Retorno220ms, inmediato con movimiento reducido; no borrar ni retirar fila por el gesto. Por instrucción posterior, solo el swipe izquierdo solicita eliminación; mantener pulsado no abre confirmación. No repetir cover/stagger durante drag.

Ajuste posterior del swipe: el tinte rojo progresivo también cubre texto, iconos y fotografía de la tarjeta. ColorFiltered sobre contenido completo, intensidad ligada al recorrido; al volver a cero recupera colores originales. Mantener el nodo del filtro y de la imagen durante el gesto/retorno para evitar remonte/parpadeo. No alterar archivos ni imágenes almacenadas.

Corrección de intensidad: rojo contextual de swipe #C12F3D, progresión easeOutCubic para reducir apariencia rosada tenue en recorrido parcial. Texto e iconos cambian progresivamente a rojo claro #FFE3E6, en lugar del salto entre negro/blanco por luminancia. Tinte común de fotos/contenido aumenta hasta32%; al retornar se recuperan colores originales. No modificar la paleta neutra del resto de la app ni el danger suave de confirmación.

La confirmación de eliminación usa expansión desde la tarjeta restaurada, sin cover/stagger. Transformar primero la superficie y desvanecer el contenido de origen; presentar el nuevo contenido en la última parte de la expansión, sin hacerlo visible de golpe al inicio. OriginDialogTransition dura320ms y respeta movimiento reducido. OriginPageTransition adopta también aparición tardía del contenido (desde65%). Mantener acciones iguales abajo a la derecha y permitir scroll con texto ampliado; cabecera adapta el cierre para no partir palabras por falta de ancho. Véase ADR-006.

Tarjeta de Mis mascotas más compacta por ajuste explícito: separar nombre y texto secundario con2; alturas de línea1.2/1.25 respectivamente. Padding vertical14 y horizontal20, foto56 conservada. Permitir crecimiento por nombres largos/texto ampliado, sin altura fija ni recortes. La copia visual del origen comparte estas dimensiones.

Corrección posterior: color de texto/iconos y tinte de foto comienzan desde el primer movimiento del swipe y comparten easeOutCubic con el fondo. Sin espera ni intervalo corto que provoque salto brusco; retorno recorre la misma progresión. Cierre de confirmación contrae superficie sin reintroducir copia de texto/foto de origen; desvanece overlay al llegar y revela tarjeta real inmóvil. Evitar animación implícita adicional del Material sobre morph. Apertura y movimiento reducido conservados.

Actualización de registro compacto: con mascotas, sustituir + Mascota por círculo negro #111111 de56 con icono + blanco de26, sin texto visible, a la derecha. Mantener tooltip/nombre accesible Registrar mascota y expansión desde límites reales del círculo. Vacío conserva botón completo debajo de huella. Esta instrucción sustituye geometría/color/etiqueta de la variante compacta descrita antes.

Mantener posición de Mis mascotas al aparecer el círculo: cabecera horizontal reserva56 para la acción aun durante carga/vacío, con misma geometría de título. Con poco ancho/texto ampliado, título permanece arriba y acción se dispone debajo a la derecha. La aparición de la acción no debe desplazar el título.

## Ficha con identidad de la mascota, 9 de octubre de 2026

Por solicitud explícita del usuario, la ficha omite el título genérico «Ficha de mascota»: el nombre es el encabezado accesible. La galería privada se coloca encima, con fotos cuadradas de hasta160 y radio22; la huella solo aparece cuando no hay fotos y la consulta no ha fallado. Errores/reintento de fotos siguen contextuales. El retorno de la ficha usa chevrón en círculo glass de52 con tooltip y área táctil completa, reutilizando el acabado de la navegación desde core. Esta autorización amplía el glass a ese control; Registrar y Editar también reutilizan este retorno según ADR-015.

Corrección solicitada: el retorno glass de la ficha flota sobre el scroll mediante Stack; no reservar una franja opaca ni recortar el contenido bajo una cabecera. El scroll puede pasar por detrás del control y por la zona superior; la posición del botón respeta SafeArea. El padding inicial deja las fotos debajo del botón antes de desplazar.

La huella de ficha sin fotos ocupa el mismo tamaño cuadrado que la imagen (hasta160, calculado con el mismo ancho disponible) y mantiene separación20 hasta el nombre. No usar una huella pequeña que cambie la posición del encabezado.

## Navegación glass compartida, 9 de octubre de 2026

Por instrucción explícita del usuario, todos los controles superiores de retorno/cierre de pantalla usan GlassNavigationButton compartido: círculo52 con acabado de GlassSurface, chevrón para volver o X para cerrar, icono28, tooltip y área táctil completa. El control flota encima del scroll sin franja opaca; respetar SafeArea/insets y reservar espacio inicial. Esta regla sustituye las dimensiones previas del cierre plano y las excepciones por formulario. Mantener destinos, acciones y movimiento reducido. Ver ADR-015. No confundir navegación de pantalla con controles de campos, retirada de fotos o cierre de paneles/modales.

Tamaño de mascota usa tres opciones de igual ancho que, junto con dos separaciones8, ocupan todo el ancho del formulario. Sin scroll horizontal ni espacio sobrante al extremo. Etiquetas/iconos se disponen en columna al faltar ancho o ampliar texto, sin reducir fuente ni truncar; mantener selección, deselección y bloqueo.

## Salida de Registrar/Editar mascota

Al volver mediante retorno glass o Atrás del sistema, pedir confirmación solo si hay cambios sin guardar: campos o fotos pendientes. Registro vacío y edición intacta/restaurada salen directamente. Modal «¿Salir sin guardar?» ofrece «Seguir editando» (conserva el borrador) y «Salir sin guardar» (descarta campos/fotos pendientes); tocar fuera o Atrás del modal equivale a seguir. Impedir confirmaciones duplicadas y salida mientras se guarda/procesa foto. Guardado confirmado sale sin preguntar. Reutilizar el patrón de modal neutro y transición compartida, con scroll/texto ampliado/movimiento reducido.

## Apertura de ficha desde la tarjeta, 9 de octubre de 2026

Por instrucción explícita del usuario, abrir los detalles de una mascota existente desde Mis mascotas reutiliza OriginPageTransition de Registrar mascota: expansión desde los límites reales de la tarjeta en coordenadas del Navigator, apertura320ms y contracción260ms al volver. Movimiento reducido muestra el destino directamente. Mantener continuidad de skeleton y resolución sin repetir cover/stagger según ADR-011. Entradas sin tarjeta de origen, incluido guardado confirmado, conservan su navegación previa.

## Editor de mascotas: validación y fotos — ADR-016

Por instrucción explícita del usuario, Registrar/Editar amplía fotos a cuadrados de hasta160, igual que ficha, con radio22/scroll horizontal. Fotos opcionales. Nombre/especie/tamaño/edad/rasgos obligatorios; tipo obligatorio si Otra. Sexo opcional, Macho inicial y No lo sé disponible. Especie muestra Seleccionar hasta elegir; placeholder fuera de opciones. Rasgos o descripción incluye0/200 dentro del campo y límite200.

Los campos inválidos muestran únicamente borde/texto/icono danger y ShakeField compartido con login; no usar textos de error debajo ni indicadores adicionales. El toast superior compartido explica campos incompletos, valores inválidos y errores de guardado/fotos del editor; conflicto ofrece Ver ficha actual. Intento nuevo repite feedback, edición limpia la marca del campo editado y conserva los demás. Movimiento reducido mantiene contenido accesible sin shake. Otras funcionalidades y errores de fotos de la ficha conservan feedback anterior. [ADR-016](decisiones/016-validacion-formulario-mascotas.md) sustituye las reglas previas solo para este editor.

## Selector Activas/Archivadas — 9 de octubre de 2026

Por referencia explícita del usuario, este selector usa una sola cápsula gris con dos segmentos y selección carbón/texto blanco, sin check ni bordes separados. El indicador y el color de ambas etiquetas transicionan juntos con el mismo progreso320ms/easeInOutCubic de selección local, respetando movimiento reducido; no vuelve a revelar la pantalla al seleccionar. Mantener tipografía/áreas táctiles y ambos textos completos; al ampliar texto, permitir disposición vertical dentro de la misma cápsula si la fila no cabe. Detalles en DISENO_UI.

## Morph de Registrar mascota — 9 de octubre de 2026

La expansión de registro conserva inicialmente la identidad del botón: carbón, radio24 en vacío o círculo56/radio28 con mascotas, icono y etiqueta reales. La superficie se transforma progresivamente en pantalla blanca; la copia del origen se desvanece antes de mostrar el formulario. El cierre invierte el morph y recupera el botón. Reutilizar OriginPageTransition/OriginPageSource, sin controles activos ni anuncios duplicados en la copia, con movimiento reducido inmediato. Véase ADR-006.

## Activación local de Reportar mascota perdida — 10 de octubre de 2026

HU-05 implementa la acción Mascota perdida desde Reportar y la consulta Mis casos; Mascota encontrada mantiene disponibilidad posterior de HU-06. El nuevo formulario conserva geometría/componentes aprobados, cabecera persistente fuera del reveal, retorno glass, cover seguido de stagger por etapa y scroll al inicio al cambiarla. Referencia/punto exactos privados; selección explícita de fotos y revisión pública antes de enviar. Validación/errores contextuales (ADR-005), sin extender las excepciones de toast de Registrar/Editar mascota a este flujo. Confirmación persistida como etapa; consultas con skeleton inicial y progreso fino en refresh, conforme ADR-011.

## Activación local de Reportar mascota encontrada — 10 de octubre de 2026

HU-06 activa Mascota encontrada y Mis encontrados desde Reportar. Reutiliza el shell de casos en core, glass flotante, cabecera fuera de cover/stagger y feedback contextual (ADR-005), sin ampliar excepciones de toast. Título Reportar hallazgo conserva tamaño32 y evita partir la palabra encontrada con texto ampliado. Draft pendiente siempre se distingue de publicación; su limpieza pide confirmación y no anuncia éxito antes de completarse. Las reglas previas se mantienen; véanse DISENO_UI y ADR-022.


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](decisiones/023-feedback-reportes-toast-superior.md).


## Reutilización de carga y confirmaciones — 10 de octubre de 2026

Resolver skeleton a datos/vacío/error pertenece a la misma entrada: AuthStageTransition conserva el subárbol cuando vuelve a habilitarse después de carga; ContentReveal conserva su historial de skeleton. Vista previa/confirmación siguen siendo cambios discretos con cover seguido de stagger. No usar un nuevo reveal por terminar una consulta.

Todas las confirmaciones de salir/descartar/archivar/eliminar delegan en confirmActionDialog de core: ruta, transición OriginDialogTransition, superficie centrada/ancho máximo420, padding24, cabecera/cierre, scroll y acciones. Se conserva la geometría aprobada de eliminación: pareja de botones con igual tamaño, alineados a la derecha, cancelar primero y confirmar después; se apilan según ancho/texto medido. Altura mínima48 y radio18, ampliables; el tamaño del contenido y las etiquetas pueden variar sin cambiar la regla de composición. Solo texto, semántica, origen de apertura y carácter destructivo se parametrizan. Los wrappers de funcionalidad no construyen botones ni layout.


## Reporte perdido: mapa y fotos compartidas — 10 de octubre de 2026

Por instrucción del usuario, HU-05 retira campos/lectura de coordenadas numéricas del formulario: selección manual en mapa sin GPS, preservando coordenadas privadas internamente. Fotos del formulario y vista previa reutilizan PhotoGalleryStrip/PhotoGalleryTile de core, extraídos de la galería de mascotas; misma geometría de detalle112–160, separación10, radio22 y scroll horizontal. Selección de fotos públicas pertenece al ViewModel del reporte, sin cambiar principal ni contenido privado de la mascota. No copiar galerías con disposición vertical al incorporar este recorrido.


## Vista previa de publicación inmersiva — 10 de octubre de 2026

Por referencia e instrucción explícita del usuario, perdidos/encontrados comparten CasePublicationPreview: fotografías protagonistas deslizables a ancho completo, indicador de foto, nombre/especie destacado y panel inferior GlassSurface con datos y acciones reales. CaseScreenShell conserva retorno glass, cabecera fuera de la transición, scroll y cover→stagger por etapa; se eliminan márgenes/cabecera de formulario solo en vista previa. La galería del formulario sigue usando PhotoGalleryStrip/PhotoGalleryTile; la vista previa sustituye sus tiles por el pager protagonista. primaryActionButtonStyle, LoadingShimmer y toast mantienen implementación única.

ExpandableDescription comparte contracción a dos líneas y expansión/contracción al tocar el texto, con AnimatedSize320ms/easeInOutCubic. Movimiento reducido presenta contenido inmediatamente. No reproduce el reveal ni cambia foto, borrador o envío al expandir. Se permite scroll y crecimiento con texto ampliado. Datos privados/funcionalidades de venta de la referencia no se añaden. Decisión y revisión en [ADR-024](decisiones/024-vista-previa-publicacion-inmersiva.md).


## Scroll continuo hasta el área del gesto — 10 de octubre de 2026

Por captura e instrucción del usuario, las páginas con scroll usan ScrollSafeArea de core: el viewport llega al borde inferior y no reserva una banda blanca fija con SafeArea(bottom:true). El espacio del gesto se suma al padding final del contenido y a los controles flotantes mediante bottomPadding; con teclado abierto se usa el inset efectivo, sin sumar una segunda franja. Mantener protegidos el último campo/botón y los márgenes laterales/superiores. La barra de navegación del sistema se solicita transparente, sin divisor ni contraste opaco; iconos oscuros sobre formularios y claros sobre vista previa fotográfica. Modales/onboarding mantienen sus áreas seguras específicas. Véase [ADR-025](decisiones/025-scroll-continuo-area-gesto.md).


Ficha pública y vista previa de perdidos/encontrados deben usar la misma composición CasePublicationPreview, con fotos grandes deslizables, panel glass y descripción expandible. Solo cambian título, texto preventivo y acciones según el estado del recorrido; no conservar una ficha con layout anterior. En el formulario de perdida se retiran Volver a consultar fotos y Mis casos; la recuperación de envíos ambiguos sigue disponible. Véase ADR-024 actualizado.


Actualización del 10 de octubre de 2026: por instrucción del usuario se retira el título glass flotante de la ficha/vista previa inmersiva; se conserva únicamente GlassNavigationButton para volver. Fecha del suceso a20px/negrita, con ajuste por texto ampliado. La ubicación se representa mediante ZoneMapPicker compartido en modo lectura, con la zona aproximada pública, círculo y sin marcador de punto exacto; formulario conserva edición del punto privado. Preview usa la proyección aproximada existente y ficha solo las coordenadas públicas del contrato. Errores del mapa usan toast superior compartido y conservan Reintentar mapa, sin mensajes bajo el mapa ni solicitud de coordenadas numéricas. La consulta no modifica ubicación ni captura el scroll vertical. Sustituye las indicaciones previas de título inmersivo y ubicación explicada solo por texto.


## Listas de casos consistentes con mascotas — 10 de octubre de 2026

Por instrucción del usuario, Mis casos/Mis reportes usan la implementación extraída de Mis mascotas a core: EntityCardContent/EntityCardSurface, SwipeActionCard, TwoOptionFilter, CollectionHeader/CollectionAddButton. Mascotas delega en los mismos componentes y conserva su referencia aprobada. Abiertos/Resueltos, foto real disponible y botón+ de56 reemplazan ListTile y el botón grande inferior. Swipe devuelve posición y abre confirmActionDialog común; shimmer/errores/confirmación siguen el patrón existente. Borradores encontrados conservan descarte con superficie compartida. Presentación consume ViewModels/casos de uso; dominio no adquiere dependencias de Flutter/SDK. Incremento de gestión por dueño solicitado sobre HU-05/RF-05 y HU-06/RF-06: eliminación de casos active/resolved y consulta privada de resueltos, con IDs/historial conservados y permisos versionados en016. No implica cierre de historias. Véase [ADR-026](decisiones/026-listas-casos-componentes-compartidos.md).

## Apertura coherente de fichas — 11 de octubre

Por instrucción del usuario, mascotas y casos comparten apertura/retorno desde la tarjeta mediante OriginPageTransition y entityDetailPage en composición. Capturar la tarjeta real; respetar movimiento reducido y navegación directa cuando no existe origen. Eliminar Volver a consultar de listas/fichas: Reintentar solo ante un fallo real. No añadir controles permanentes de recarga como reemplazo. Véase [ADR-029](decisiones/029-apertura-fichas-desde-tarjeta.md).


## Panel de ficha expandible — 11 de octubre de 2026

Por solicitud del usuario, ficha pública y vista previa comparten un panel inferior arrastrable con apertura por toque en el indicador; foto/pager permanecen detrás. Desaparición (Encuentro en encontrados) aparece en badge fuera del glass, junto al nombre cuando hay espacio y debajo con texto ampliado. Nombre con sombra leve, máximo dos líneas y elipsis; la etiqueta accesible conserva el nombre completo. El mapa no se monta hasta abrir el panel; fecha, ubicación aproximada y privacidad se muestran en los datos ampliados. El contenido se desplaza dentro del panel y las acciones existentes conservan sus operaciones reales. Movimiento reducido desactiva animación y snap; no se reproduce reveal durante gestos. Véase [ADR-030](decisiones/030-panel-ficha-expandible.md).


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.


## Consistencia de formularios perdido/hallazgo — 11 de octubre de 2026

Corrección explícita del usuario tras detectar controles extra en hallazgo. Se retiran Latitud/Longitud, Usar coordenadas, lectura numérica del punto, Recuperar foto interrumpida y el acceso permanente Mis encontrados dentro del formulario. CaseLocationFields de core compone ambos formularios con la misma selección en mapa, instrucciones de privacidad, referencia privada, invalid/shake y stagger; solo cambia el título del suceso y los callbacks del ViewModel. Coordenadas continúan internas, sin nueva captura numérica ni GPS. Fecha/hora siguen compartidas por ADR-032. Fotos usan la misma etiqueta pública y galerías/controles compartidos.

Se conservan las diferencias propias del producto: perdido elige mascota/fotos registradas; hallazgo describe y fotografía una mascota sin dueño conocido y permite custodia opcional. Consultar la lista permanece solo ante envío ambiguo, igual en ambos recorridos. La API de recuperación de fotos permanece para el ciclo de vida existente, sin botón técnico permanente ni afirmación de recuperación automática nueva. [ADR-033](decisiones/033-formularios-reportes-consistentes.md).

Validación:50 pruebas de reportes, entrada real, preview, arquitectura y consistencia aprobadas; análisis sin incidencias. Las8 pruebas de creación verifican controles retirados ausentes, uso del bloque común, punto del mapa entregado al estado y ausencia de coordenadas visibles, tamaños390×844/320×350 texto2 y movimiento reducido. Capturas regeneradas y revisadas; no acreditan fotos/teselas reales. Revisión Android pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](funcionalidades/busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


Selección de origen Mi mascota/Otra mascota: conservar cabecera/selector y datos de ambas opciones durante la visita; cambiar únicamente el cuerpo sin navegación/refetch ni reproducción de entrada. Cambio inmediato de cuerpo sin transición entre opciones; skeleton únicamente ante datos inicialmente pendientes. Entrada real y pasos de revisión conservan cover/stagger. [ADR-035](decisiones/035-alternar-origen-sin-recargar-formulario.md).


Reportar es panel de elección de creación: dos opciones de igual jerarquía con explicación breve. Por instrucción del usuario, sin Cerrar ni enlaces Mis casos/Mis búsquedas y avisos. Mantener gesto/barrera/Atrás, accesibilidad e insets; consulta por un único acceso Mis reportes en Inicio. Reutilizar CollectionAddButton con descripción y su origen de apertura, y componentes aprobados de colección. [ADR-036](decisiones/036-reportar-y-mis-reportes.md).


Instrucción vigente del12 de octubre: Reportar crea pérdida directamente, sin Mascota encontrada o panel intermedio. Avisar vista/hallazgo solo desde ficha abierta, destino fijo sin catálogo/dropdown. Sustituye panel de ADR-036. Mis reportes reúne consulta/gestión; no presentar Explorar como implementado hasta entregar HU-07. [ADR-037](decisiones/037-avisos-desde-ficha.md).


## Explorar en grilla fotográfica — 15 de octubre de 2026

Por instrucción explícita del usuario, Explorar usa cards con foto protagonista de inspiración Apple. Por aclaración posterior del usuario con captura, dos columnas completas con margen lateral12 y separación14; desplazamiento únicamente vertical, sin cards cortadas al costado. Título/filtros conservan margen24. Una columna del ancho disponible en superficies estrechas o texto ampliado. Por ajuste posterior del usuario: imagen horizontal4:3, sin fecha en la card y estado como badge en la esquina superior derecha; nombre/tipo/especie y distancia debajo, radios22 y superficies neutras compartidas; alturas naturales y texto completo. Skeleton con la misma disposición, foto con CasePhotoView y feedback existente, sin imagen ficticia para registros sin foto. La tarjeta completa abre la ficha y conserva el origen real/cover→stagger, filtros y páginas. Es una dirección específica de Explorar. [ADR-040](decisiones/040-explorar-grilla-fotografica.md).


## Filtros flotantes con cápsulas compartidas — 15 de octubre de 2026

Por instrucción explícita del usuario, Filtrar casos abre un panel superpuesto, sin ExpansionTile ni desplazamiento de la grilla. FilterPopover/FilterChoiceGroup reutilizables viven en core; SelectionPillSurface se comparte con TwoOptionFilter, referencia de Activas/Archivadas. SuperficieE5E5EA, selección negra, texto blanco, padding6/radios32–26 e indicador único320ms con movimiento reducido respetado. Opciones se redistribuyen según ancho y texto real. Ventana blanca/radio28, X glass, cabecera estable y scroll propio accesible; entrada cover→stagger del cuerpo. Cerrar por X/fuera/Atrás descarta cambios no aplicados; aplicar inicia la consulta existente. La ruta se retira con su propietario/cuenta. [ADR-041](decisiones/041-filtros-flotantes-reutilizables.md).


## Filtros integrados y zona con buscador — 15 de octubre de 2026

La nueva instrucción del usuario sustituye el popup de ADR-041: desplegar filtros ahí mismo, con cápsulas compartidas. FilterExpansion en core conserva el disparador y despliega el editor dentro del scroll vertical, sin rutas modales. Cerrar descarta borrador; aplicar colapsa y confirma. Movimiento reducido monta directamente; demás entradas cover→stagger sin reinicio por edición. Separación16 entre control y cards, nombre/especie debajo y tipo/estado en badges, sin texto repetido Mascota perdida. Zona combina búsqueda explícita de ciudad/dirección, selección en mapa y slider1–50km, con carga/errores según norma. [ADR-042](decisiones/042-filtros-integrados-y-busqueda-zonas.md).
