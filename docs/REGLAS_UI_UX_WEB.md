# Entre Huellas: reglas de UI y UX web

Estado: norma para el desarrollo web. Aprobada por el usuario el 18 de octubre
de 2026, America/Lima, tomando la landing terminada como referencia.

## 1. Referencia y alcance

La plataforma `apps/platform` (Vue/Nuxt/TypeScript) debe continuar la identidad
visual de la landing aprobada en `/`: cálida, clara, amable y con protagonismo
de las mascotas. Esta base aplica a los recorridos públicos, de usuarios y de
administración. Los permisos cambian las operaciones disponibles, no crean
marcas o sistemas visuales distintos.

Leer este documento junto con [REGLAS_UI_UX](REGLAS_UI_UX.md),
[REGLAS_ARQUITECTURA](REGLAS_ARQUITECTURA.md) y [DISENO_UI](DISENO_UI.md).
[ADR-063](decisiones/063-landing-como-referencia-ui-ux-web.md) extiende a la web
la referencia que ADR-060 limitaba a la landing. Flutter conserva su referencia
actual. Las reglas globales de feedback, carga, privacidad y arquitectura siguen
vigentes. Las notas históricas de paletas intermedias no sustituyen esta base.

Esta norma no afirma que los componentes actuales del lector QR ya tengan estos
estilos. Se adaptarán al intervenir cada recorrido, con revisión de regresión.
Tampoco implica que existan acceso web, panel de usuario o administración.

## 2. Fuentes reales de la referencia

| Fuente | Qué consultar |
| --- | --- |
| [landing.css](../apps/platform/app/features/landing/presentation/styles/landing.css) | Valores, cascada final, variantes y media queries aprobadas. |
| [LandingPage.vue](../apps/platform/app/features/landing/presentation/screens/LandingPage.vue) | Composición, jerarquía, textos, anclas y FAQ. |
| [Widgets de landing](../apps/platform/app/features/landing/presentation/widgets) | Marca, acciones, iconos, tarjetas e ilustraciones. |
| [LANDING_ASSETS](../apps/platform/LANDING_ASSETS.md) | Recursos independientes, dimensiones y procedencia. |
| [Ficha de landing](funcionalidades/landing-page.md) | Recorrido, límites y evidencia de validación. |

El código documenta la implementación actual; este archivo fija qué conservar y
cómo extenderlo. Al cambiar una regla aprobada se actualizan ambos y se registra
la decisión. No copiar declaraciones antiguas ignorando los overrides finales.

## 3. Paleta y superficies

| Uso | Valor aprobado |
| --- | --- |
| Fondo crema | `#FFFBEF` (`--cream`). |
| Texto principal | `#171918` (`--ink`). |
| Texto secundario | `#656861` (`--muted`). |
| Azul de marca | `#3C537B` (`--brand-blue`). |
| Acento azul | `#2C87CE` (`--brand-accent`). |
| Celeste | `#B5D5E9` (`--brand-sky`). |
| Superficie azul tenue | `#EDF5FA` (`--brand-mist`). |
| Superficie de contenido | Blanco, sobre crema o fondos suaves. |

El fondo general de landing combina crema con un radial `#fffdf8` transparente.
Usar superficies claras, texto oscuro y separación por espacio, radios y color;
evitar convertir todo el sistema en bloques de azul saturado o sombras pesadas.
Azul de marca y azul de acción son usos distintos: el botón principal aprobado
tiene degradado, no fondo plano `#3C537B`.

La landing conserva deliberadamente variantes por sección:

- Hero: aurora multicolor original, con verde/lima/celeste/lavanda; mascotas
  pequeñas originales y valores blancos. No reemplazarla por la aurora azul.
- Oportunidad, comunidad y colaboración: colores originales restaurados.
- Cierre «Una huella tuya»: aurora azul/celeste/lavanda aprobada.
- Pasos 01–04: numeración `#171918`, sin los pines CSS retirados en 02/03.

Estas composiciones sirven para presentación institucional. En formularios,
tablas y lectura de datos usar fondos tranquilos que mantengan la jerarquía.
Lima es un acento de marca; no significa éxito por sí mismo. Los colores de
error/éxito deben tener semántica explícita, icono o texto accesible y contraste
verificado. La landing informativa no define una paleta completa de estados.

## 4. Tipografía y jerarquía

La familia real aprobada es `Arial, Helvetica, sans-serif`. No añadir otra fuente
como parte de una nueva pantalla sin registrar el cambio de referencia.

| Elemento de landing | Regla real |
| --- | --- |
| Títulos h1/h2/h3 | Peso `500`. |
| h1/h2 | Tracking `-0.055em`, interlineado `1.02`. |
| Hero h1 escritorio | `clamp(42px, 7vw, 108px)`. |
| Hero h1 móvil | `clamp(32px, 8.5vw, 48px)`. |
| Título de sección | `clamp(29px, 4.3vw, 58px)`; a ≤600px, `34px`. |
| Párrafos base | Interlineado `1.3`, con ajustes de lectura por sección. |
| Botón | Peso `600`, tracking `-0.035em`. |
| Marca visible | «entre huellas», minúsculas y peso `500`. |

En páginas de trabajo conservar familia, pesos y jerarquía, adaptando la escala
a la tarea. Los 108px del hero no son una medida para títulos de formularios.
Los textos pequeños del pie y de la composición compacta de landing tampoco
definen la escala de inputs o tablas. Definir y revisar la escala de esos
componentes cuando se implementen; nunca reducir texto para ocultar overflow.
Usar un h1 por página y encabezados semánticos ordenados.

## 5. Composición, espacios y radios

- Contenedores de landing alineados mediante `.wrap`: ancho
  `calc(100% - clamp(24px, 4vw, 64px))`, sin máximo de 1280px.
  En móvil ≤600px, `calc(100% - 28px)`: 14px a cada lado.
- Separación entre secciones posteriores a propósito:
  `clamp(40px, 6vw, 88px)`. Separación anterior al pie:
  `clamp(24px, 3vw, 48px)`.
- Radio principal de panel: `clamp(23px, 3.2vw, 42px)`.
  Las tarjetas interiores mantienen radios menores según su función; no todo
  tiene que ser una cápsula.
- Usar grid/flex y columnas `minmax(0, 1fr)`, hijos con `min-width: 0` cuando
  corresponda y contenido que pueda crecer con texto ampliado.
- Hero casi de primera pantalla: `100svh` menos cabecera/margen, como altura
  mínima. Las páginas operativas crecen con su contenido y su tarea.
- Formularios pueden limitar el ancho de lectura dentro del contenedor común;
  listados/tablas pueden aprovechar más espacio. Conservar alineación y aire
  sin copiar la distribución de una sección publicitaria a todas las pantallas.

No introducir alturas fijas que corten contenido, acciones o avisos. El pie
aprobado tiene texto entre mascotas completas en escritorio; en móvil el texto
precede a las dos mascotas en una segunda fila. No recortar cabezas ni cruzar
ilustraciones con enlaces. Esto no obliga a poner ese pie en cada panel privado.

## 6. Botones y navegación

Todos los botones siguen la forma cápsula `border-radius: 999px`, incluidos
secundarios y variantes responsive; los controles solo de icono son circulares.

| Variante | Apariencia aprobada |
| --- | --- |
| Principal azul | `linear-gradient(180deg, #75bfff 0%, #459ff6 48%, #2887ef 100%)`, texto blanco. |
| Secundario de marca | `linear-gradient(145deg, #e5f2fa, #b5d5e9)`, texto `#3C537B`. |
| Principal en hero/oportunidad/comunidad | `linear-gradient(160deg, #eaff9c, #c3fb56)`, texto `#171918`. |
| Secundario en hero/oportunidad | `linear-gradient(145deg, #d1f6ff, #a6e5fa)`, texto `#171918`. |

Cabecera y principal del cierre añaden brillo superior y sombra suave:
`inset 0 1px 2px #ffffff80`, `0 7px 20px #2887ef40`,
`0 2px 5px #2887ef1a`; texto con sombra `0 1px 2px #155ba94d`.
No volver al primario azul plano ni a la propuesta celeste con texto oscuro.

Botón base: altura mínima 44px, padding 12px 24px, texto
`clamp(11px, 1.08vw, 14px)`. En móvil, padding 12px 16px y mínimo 44px.
La landing tiene excepciones compactas en cabecera/tablet; no trasladar sus
alturas de 26–36px automáticamente a los controles de formularios. Para nuevas
acciones táctiles mantener al menos 44px de área interactiva.

Hover aprobado: elevación de 2px, brillo `0.97`, transición de 0.2s. No desplazar
otros elementos. Con movimiento reducido, sin traslación. Conservar foco visible:
contorno de 3px y offset 5px, azul de acento; en secciones lima, `#207286`.
Extender foco a botones e inputs nuevos, no solo a enlaces/summary de landing.

Enlace para navegar y botón para ejecutar. Etiquetas concretas, acciones reales,
estado deshabilitado comprensible y envío duplicado bloqueado. Retorno/cierre
conserva el patrón glass circular compartido cuando corresponda, con nombre
accesible y área táctil; no añadir barras opacas por defecto.

## 7. Marca, ilustraciones e iconos

Usar logo oficial, sin recrearlo ni deformarlo. Mantener PNG/SVG de marca y
favicon sincronizados mediante el flujo existente. Los recursos de landing son
imágenes independientes con transparencia; textos, tarjetas, botones, fondos y
decoraciones siguen siendo HTML/CSS/SVG. No usar capturas de la landing como UI.

Conservar estilo y variedad de mascotas, pañuelos y emblemas aprobados. El hero
usa `hero-dog.png` y `hero-cat.png`; no sustituirlos por variantes del resto.
`dog-report.png` conserva la corrección de anatomía aprobada. Consultar el
manifiesto antes de reemplazar recursos. Dimensionar imágenes para evitar saltos,
cargar diferidamente las que no son críticas y comprobar su decodificación.

Los iconos usan un lenguaje consistente y nombre accesible si actúan solos.
Las ilustraciones decorativas no duplican anuncios de lectores de pantalla.
No poblar pantallas operativas con mascotas decorativas que compitan con fotos,
campos o acciones de los casos reales.

## 8. Movimiento

Conservar cover reveal y stagger reveal en entradas y cambios discretos de etapa,
con cabeceras persistentes fuera del efecto. Valores reales del hero: cover 0.7s
con `cubic-bezier(0.2, 0.7, 0.2, 1)`; stagger 0.55s, opacidad y traslación 9px,
retrasos 0.2/0.3/0.4/0.5s. No repetir entrada al escribir, abrir teclado,
actualizar contadores, refrescar datos o mover un gesto.

La fila de personajes es específica de landing: avance horizontal 120s, onda 6s,
doce fases cada 0.5s y amplitud adaptable de 24–56px. Conservar continuidad,
control de pausa y copias decorativas sin duplicar mensajes accesibles.
No extender animaciones infinitas a tablas o formularios.

Respetar `prefers-reduced-motion`: sin animaciones/transiciones decorativas ni
scroll suave obligatorio. El contenido debe permanecer visible y operable.

## 9. Formularios, feedback y estados de datos

La landing no tiene formularios ni operaciones remotas. Para los recorridos
web nuevos aplicar las reglas globales, sin inventar que esos estados ya están
implementados en la landing:

- Etiquetas persistentes, instrucciones de privacidad claras y campos requeridos
  identificables; placeholder no sustituye etiqueta. Validación de negocio fuera
  del componente visual y autorización en servidor.
- Errores, validación y resultados mediante toast superior compartido. Mantener
  borde/estado inválido y shake danger con movimiento reducido respetado.
  Sin mensajes de error bajo inputs, `errorText`/`helperText`, SnackBar ni barra
  inferior equivalente. Conservar datos e instrucciones, no convertirlos en toast.
- Asociar semántica de invalidez, anuncios y foco accesible al campo pertinente.
  Toast ligado al ciclo de vida, sin repetir por rerender ni revelar fallos del SDK.
- Skeleton en carga inicial; en refresh de la misma identidad conservar contenido
  con shimmer. Botones mantienen etiqueta y usan LoadingShimmer solo durante
  trabajo real. Sin spinners, barras de progreso o textos visibles de carga.
- Estado vacío solo tras ausencia confirmada; error tiene recuperación real.
  Un fallo no se presenta como lista vacía. Ocultar datos de la identidad anterior.
- Confirmar acciones destructivas y preservar borrador ante fallo cuando proceda.
  Reintentos de escritura mantienen identidad estable y deduplicación en servidor.

Reutilizar o evolucionar `WebShell`, `ActionButton`, `TopToast` y
`ContentSkeleton` existentes. Extraer estilos/variantes comunes cuando haya uso
real; no crear un segundo kit por rol ni importar presentation de landing desde
otra funcionalidad. La extracción compartida debe respetar arquitectura y CSP.

## 10. Responsive, accesibilidad y entrega

La landing usa cortes ≤600px, 601–850px y ajustes desde 1500px. Son referencias
de su composición, no una obligación de forzar todas las páginas a esas columnas.
Priorizar contenido y operación en 320px, crecimiento natural, teclado y texto
al 200%. Scroll horizontal solo dentro de regiones que lo necesiten (como tablas),
con acceso completo; no ocultar overflow global para disimular errores.

Mantener enlace para saltar al contenido, landmarks, foco visible y orden de
teclado. FAQ con `details/summary` nativo, operable sin JavaScript, apertura
exclusiva y texto real. Revisar contraste por combinación final: no asumir que
la aprobación visual o el contraste de una versión azul plana certifican el
degradado actual. Objetivo de lectura: WCAG AA, 4.5:1 en texto normal y 3:1 en
texto grande; también comprobar foco y controles. No se declara auditoría AA
global completada con este documento.

Criterios para aceptar cada incremento web:

- Identidad de esta guía, componentes reutilizados y operaciones autorizadas.
- Renders en 1440, 731, 390 y 320px; 1920px para ancho/alineación y texto 200%
  en tamaño pequeño. Sin recortes, cruces ni acciones inaccesibles.
- Teclado, foco, movimiento reducido, estados reales y recuperación verificados.
- En landing: anclas/FAQ, ilustraciones, auroras visibles y pausa de personajes.
- Navegación landing → QR → landing sin contaminación de CSS ni regresión de datos.
- SSR/hidratación sin errores, consulta duplicada ni exposición de datos privados;
  sin relajar CSP para estilos o recursos. SEO público solo donde está autorizado.
- Según el cambio: `npm run typecheck`, `npm test`, `npm run build` desde
  `apps/platform`; pruebas de servidor/navegador pertinentes según
  [DESARROLLO](../apps/platform/DESARROLLO.md). El script
  [check-landing-browser.mjs](../apps/platform/scripts/check-landing-browser.mjs)
  requiere su entorno de navegador y servidor; no asumir que es un npm script.
- Registrar evidencia, pendientes y siguiente paso en ESTADO y ficha funcional.
  Una revisión Chrome local no certifica Safari/Firefox ni despliegue remoto.

## 11. Evolución

Los componentes nuevos deben expresar esta misma identidad y resolver una tarea
real. Documentar sus dimensiones y estados al implementarlos. No crear pantallas,
permisos ficticios, métricas, datos simulados o catálogos vacíos para completar
una apariencia. Cambiar paleta, tipografía o lenguaje de interacción requiere
decisión explícita y actualización de reglas, componentes y validación afectada.
