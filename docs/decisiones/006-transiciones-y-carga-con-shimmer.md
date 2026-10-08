# ADR-006: transiciones de etapa y carga con shimmer

Fecha: 8 de octubre de 2026. Estado: aceptada por instrucción del usuario.

## Contexto

El usuario solicita una UX consistente con cover reveal seguido de stagger reveal en los lugares apropiados, incluido el resultado Contraseña actualizada. Rechaza etiquetas de carga con puntos suspensivos, como Enviando…, y pide shimmer como indicador de trabajo en curso. La marca debe permanecer estable durante las etapas de acceso.

## Decisión

- Para entrada de pantallas y cambios discretos de etapa, reutilizar AuthStageTransition/CoverReveal y StaggerReveal: cortina plana de 320 ms, seguida del timeline compartido. Cabeceras persistentes quedan fuera de la animación. No añadir expansión desde el botón a estas etapas.
- Aplicar ahora a login, registro/confirmación, recuperación/código/reset/resultado/error y al contenido de Inicio. El onboarding conserva PageView, su interacción continua y el reveal textual ya acordado; no superponer una cortina por cada frame del gesto. En futuras pantallas, elegir la unidad de entrada/etapa que ayude a entender el cambio.
- No reiniciar efectos al escribir, abrir teclado, cambiar visibilidad de contraseña, actualizar contador, presentar error de campo o reenviar en la misma etapa. Los errores contextuales siguen visibles junto al control según ADR-005.
- Nunca usar puntos suspensivos ASCII o Unicode como indicador de carga de botones. Mantener la etiqueta de la acción y mostrar LoadingShimmer durante la operación real. En botones, reemplazar también los spinners por el componente compartido. No mostrar shimmer por estar simplemente deshabilitado ni por la espera de reenvío.
- Mantener dimensiones, radios, contraste y bloqueo de dobles envíos. El lector de pantalla recibe una etiqueta de progreso breve sin puntos suspensivos, estado deshabilitado y liveRegion; el brillo no repite anuncios por frame.
- Cada nueva carga reinicia el barrido desde el borde inicial; conservar su fase durante reconstrucciones de la misma operación. Atenuar el contenido del botón a opacidad 0.72 mientras carga y pintar el brillo encima, manteniendo la etiqueta legible. Al finalizar se recupera su apariencia normal.
- Respetar movimiento reducido: etapas inmediatas y shimmer estático. Detener/liberar animaciones cuando finaliza el trabajo o se desmonta la UI.

## Alternativas

Texto animado con puntos suspensivos y spinners de botón se descartan por instrucción explícita. Un cover por edición/contador o durante todos los gestos del onboarding se descarta por interrumpir interacción y repetir cambios que no constituyen nuevas etapas. Paquetes externos de shimmer no son necesarios para un barrido simple con CustomPainter.

## Consecuencias y transición

LoadingShimmer pertenece a core/presentation/widgets. Los ViewModels siguen controlando el trabajo; la decoración no simula finalización ni modifica reglas de Auth. Verificación y reenvío de OTP se distinguen en estado para iluminar el control correcto. Se añade comprobación automática de etiquetas de UI sin puntos suspensivos. Se actualizan AGENTS, reglas, arquitectura, diseño y estado en el mismo incremento.

Validación: análisis/formato, prueba de política, pruebas de bloqueo/semántica/movimiento reducido/desmontaje, flujos de Auth, secuencia de resultado y renders. Percepción/rendimiento en Android y operaciones remotas se verifican por separado; esta decisión no afirma que ya se hayan probado.
