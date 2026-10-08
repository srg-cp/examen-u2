# Entre Huellas: regla de oro de UI y UX

Estado: **norma obligatoria**. Aprobación de la dirección visual por el usuario: 8 de octubre de 2026. Plataforma de referencia: aplicación móvil Flutter, Android primero.

## 1. Regla principal y autoridad

**Cada pantalla debe sentirse parte de la misma aplicación que Iniciar sesión, Crear cuenta, Recuperar contraseña, Revisa tu correo, Nueva contraseña y Contraseña actualizada. Se reutilizan su lenguaje visual, geometría, componentes, estados y secuencia de interacción.**

Estas pantallas implementadas son la referencia aprobada. El mockup orienta el producto, pero los ajustes posteriores del usuario definen el resultado. Las instrucciones explícitas del usuario prevalecen sobre esta norma. Una propuesta diferente debe presentarse como un cambio deliberado de diseño y actualizar este documento; no introducir otra identidad por comodidad del framework.

Esta norma sustituye la dirección antigua de fondos crema, superficies menta/durazno, tarjetas grandes y botones tipo píldora como estilo general. El antiguo Inicio con AppBar y «Tu comunidad» queda retirado y no es referencia. El Inicio provisional conserva solo una bienvenida y cierre de sesión real con los componentes aprobados; no constituye el diseño definitivo del módulo.

Leer esta norma antes de cualquier cambio visual junto con [las reglas de arquitectura](REGLAS_ARQUITECTURA.md), [estado](ESTADO.md) y el sprint de [la guía](GUIA_MVP.md). [DISENO_UI.md](DISENO_UI.md) localiza implementación y revisión. [ADR-005](decisiones/005-feedback-sin-snackbar.md) y [ADR-006](decisiones/006-transiciones-y-carga-con-shimmer.md) complementan feedback y movimiento.

## 2. Identidad y composición

- Fondo blanco, composición limpia, espacio suficiente y una jerarquía clara. El verde pertenece a la marca; no colorear el fondo de la aplicación ni añadir acentos extensos sin una necesidad aprobada.
- Icono y nombre forman una sola identidad. Reutilizar BrandMark/BrandWordmark y `assets/branding/app_icon.png`; no sustituirlos por otra huella, texto o icono de Material. Conservar proporción y esquinas del asset.
- Marca, título y campos de formularios se alinean al margen izquierdo. Centrar los elementos de confirmación que ya lo requieren: mascota, título de correo, explicación, OTP y reenvío.
- No añadir una AppBar genérica, navegación inferior, tarjetas decorativas, sombras, gradientes o menús solo para llenar la pantalla. Un módulo con contenido real puede necesitar otra composición, pero conserva estos tokens y componentes. No exigir el gran encabezado del login en cada fila o pantalla de contenido.
- Cada pantalla expresa una tarea principal. Acciones secundarias quedan subordinadas y tienen comportamiento real. No añadir funcionalidades futuras, datos simulados, enlaces legales sin documentos ni controles sin acción.

## 3. Colores y tipografía

| Uso | Valor aprobado |
| --- | --- |
| Fondo de pantalla, splash y espera | `#FFFFFF` |
| Marca textual y títulos | `#111111` |
| Texto secundario e indicaciones | `#747781` |
| Acción principal | Fondo `#24282A`, texto blanco |
| Fondo de campos | `#F5F5F7` |
| Bordes normales / divisores de acceso | `#E5E5EA` |
| Borde de campo enfocado | `#818792`, ancho 1.5 |
| Iconos de campo normales | `#626773` |
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
- Nunca usar SnackBar, toast equivalente ni barra inferior de avisos. Mantener feedback contextual y su comprobación automática.

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
