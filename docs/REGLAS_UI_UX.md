# Entre Huellas: regla de oro de UI y UX

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
- Errores de campo: borde rojo de 3.5, texto/icono del campo en rojo, fondo normal, explicación local y ShakeField de 360 ms; sacudida horizontal amortiguada, amplitud inicial 4. Repetir solo ante un error nuevo. Edición permite recuperarse sin perder datos válidos.
- Fallos generales y resultados se muestran cerca de la tarea, con mensajes breves y acciones reales. No propagar mensajes técnicos/tokens del SDK.
- Nunca usar SnackBar ni barra inferior equivalente. ADR-007 permite confirmación de éxito mediante toast superior propio por instrucción del usuario; errores y validación siguen contextuales. Mantener comprobación automática y limpieza de overlay/timer al salir.

## 7. Flujos y textos de referencia

Login conserva marca, Iniciar sesión, correo, contraseña, recuperación, Ingresar, Google y Crear cuenta. Sin subtítulo, avisos de configuración/sesión o Apple. Registro conserva cuatro campos y X; sin añadir pie de retorno ni casilla legal pendiente.

Recuperación solicita correo con Enviar código. Revisa tu correo muestra mascota, indicación breve con correo real, duración confirmada si está configurada, seis casillas y reenvío tras 60 segundos. No muestra Volver a iniciar sesión; la X permite salir. No afirmar existencia de cuenta.

OTP permite teclado numérico, pegado/autofill, ceros iniciales y retroceso. Un único campo real controla seis casillas visuales; verificar automáticamente al sexto dígito y permitir reintento explícito tras fallo. No inventar códigos ni éxito local. La sesión válida decide el acceso. La duración se muestra solo con configuración confirmada; no inferirla desde el mockup.

Nueva contraseña conserva campos y visibilidad independiente, pista y errores contextuales; Guardar contraseña conduce a Contraseña actualizada con cover/stagger. Mantener cierre de sesión de recuperación al salir. Una cuenta autenticada con onboarding pendiente conserva sus tres etapas y guardado por cuenta; no introducir Omitir ni saltarlo al cambiar diseño.

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
