# ADR-044: transición de filtros inspirada en Control Center

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

## Motivo

El usuario pide una transición como el Centro de control de iPhone: el blur anterior aparecía bruscamente, faltaba oscuridad y también afectaba al selector de origen. Excluye expresamente stagger reveal de esta interacción.

## Decisión

Refinamiento solicitado por el usuario: fondo del disparador, texto/iconos y rotación del chevrón se interpolan en la misma línea temporal; el retorno empieza al iniciar cierre. Material no añade otra animación de color que retrase esa interpolación. Disparador y FilterChoiceGroup usan NoSplash/overlay transparente, igual que TwoOptionFilter en Mis mascotas, para evitar el destello claro de tinta al pulsar opciones. Se conserva la animación del indicador y la semántica de selección.

FilterExpansion<T> conserva el desplegable anclado y las cápsulas compartidas. Una sola animación coordina desenfoque progresivo de0 a16, velo negro de0 a28% y expansión/fundido del panel desde su borde superior. Apertura420ms easeOutCubic y cierre280ms easeInOutCubic, sin retrasos por elemento ni cover/stagger. El portal se retira cuando acaba el cierre para evitar el salto visual. El contenido del editor se conserva durante los frames de animación, sin recrear su estado por frame.

El recorte del fondo excluye el rectángulo redondeado del selector real: permanece nítido, sin velo y permite cerrar. Tocar fuera/Atrás/aplicar conserva su comportamiento; dobles confirmaciones se bloquean durante cierre. Al desmontar se liberan animación/portal y se descarta el cierre pendiente. Con movimiento reducido se alcanza directamente el estado final.

Es una aproximación visual en Flutter a la referencia de iPhone, no el material/compositor nativo de iOS ni una garantía de equivalencia exacta. No se añaden dependencias, datos, permisos o SQL.

Esta instrucción sustituye el blur inmediato sigma4/velo12% y cover→stagger de ADR-043 exclusivamente para este desplegable. El resto de entradas de pantalla mantiene ADR-006 y las reglas vigentes.

## Validación

Formato Dart y revisión del código/ciclo de vida. Por instrucción vigente del usuario no se ejecutan pruebas, build ni renders. Pendiente comprobar visualmente en Android la curva, intensidad, recorte del origen, cierre durante apertura, teclado y movimiento reducido. La evidencia de pruebas anterior no valida esta transición nueva.
