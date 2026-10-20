# Entre Huellas: reglas de UI y UX web

## Excepción responsive de marca en login —19/10/2026

Por referencia explícita del usuario, el login hasta600px muestra el logo76px
y «entre huellas» en dos líneas a2rem, con gap16px, margen superior52px y lateral24px.
El título queda32px después de la cabecera. Reutilizar SiteHeader/SiteBrand;
marca fuera del formulario/stagger, estable desde SSR. Esta excepción sustituye
la línea única y medidas de ADR-076/077 solo en login móvil. Escritorio, landing
y demás pantallas conservan su marca actual. [ADR-085](decisiones/085-marca-responsive-login.md).

## Fondo exterior frío fuera de landing —19/10/2026

Por instrucción explícita del usuario, todas las rutas salvo landing usan una
base compartida azul pastel `#E5EFFF` → gris frío `#F5F7FA` al55% → blanco
`#FFFFFF`. Sin crema en el fondo exterior. WebShell declara `--page-background`;
AmbientPageShell y legales lo heredan. Conservar BackgroundGlowOrb y sus luces,
intensidades, máscaras, movimiento y accesibilidad donde ya se usa.
Landing conserva sus fondos actuales; tarjetas/campos/mapas/fotos no cambian.
Esta instrucción sustituye los fondos crema anteriores fuera de landing.
[ADR-083](decisiones/083-fondo-web-frio-fuera-de-landing.md),
[ficha](funcionalidades/fondos-web.md).

## Toast deslizable —19/10/2026

Por instrucción del usuario, TopToast entra desde fuera del viewport superior
en480ms y sale hacia arriba en240ms, con gesto de descarte dedo/ratón. Sigue el
arrastre; gesto corto/cancelado retorna en420ms, hacia abajo ofrece resistencia.
Conservar toque/teclado/reintento, roles, expiración y limpieza. No ejecutar
callbacks al arrastrar. Movimiento reducido sin transiciones. Esta decisión
sustituye la entrada fade/slide180ms anterior, manteniendo glass y tipografía.
[ADR-081](decisiones/081-toast-web-deslizable.md), [ficha](funcionalidades/toast-web.md).

## Regla obligatoria de ubicación y estabilidad de marca

El logo oficial y el texto «entre huellas» se colocan juntos, en una línea,
en la cabecera superior izquierda de la web, con la posición y los márgenes
adaptables de la landing aprobada. Se aplica a landing, login, onboarding,
inicio, gestión, QR y documentos legales. En móvil permanecen arriba.

La marca queda fuera de formularios, columnas centradas, skeletons y efectos
de entrada. Conserva posición y dimensiones desde el primer render SSR,
durante hidratación, recarga y cambios de etapa: no bajar, recentrar ni reajustar
la marca al terminar de cargar. No implica una cabecera fija durante el scroll.
Las acciones y botones de retorno deben acomodarse sin desplazarla ni taparla.

Reutilizar SiteBrand/SiteHeader. Color del texto #171918; Arial/Helvetica/sans-serif,
peso500, tracking−.05em, interlineado.9 y separación7px entre logo y texto.
Texto clamp(16px,1.9vw,25px), logo clamp(25px,3.3vw,42px); hasta600px,
texto20px y logo30px, conservando proporción. No heredar fuentes/tamaños del cuerpo.

La composición de landing sigue gobernada por landing.css y el layout general
de las demás cabeceras por site-brand.css dentro de reader-shell. No introducir
reglas competidoras cuyo orden cambie entre SSR y cliente. Al modificar marca o
cabecera, comprobar paridad contra landing y estabilidad desde el primer frame
hasta después de hidratar y recargar, en escritorio/tablet/móvil y texto ampliado.

[ADR-077](decisiones/077-marca-web-compartida-referencia-landing.md).

**Marca unificada —19/10/2026:** SiteBrand/SiteHeader comparten la marca real
de landing en acceso, onboarding, inicio, gestión, QR y legales. Color#171918,
Arial500, gap7px, tracking−.05em/line-height.9; texto clamp(16px,1.9vw,25px),
logo clamp(25px,3.3vw,42px), móvil<=600px texto20px/logo30px. Misma posición
superior izquierda y márgenes de landing, fuera del stagger; sin heredar fuente
de onboarding/legales. Sustituye logo52px de bienvenida y marca grande del login.
[ADR-077](decisiones/077-marca-web-compartida-referencia-landing.md).


**Posición de marca —19/10/2026:** logo oficial + texto «entre huellas» en
la cabecera superior izquierda, con la posición, alineación y márgenes de la
landing; onboarding es la referencia aplicada. En responsive permanece arriba.
Fuera de formularios/columnas de contenido, stagger y skeletons; estable entre
etapas. Aplica a todos los recorridos web, incluido acceso y gestión. Sustituye
las posiciones previas de marca dentro del contenido; no exige cabecera fija.
[ADR-076](decisiones/076-posicion-unificada-marca-web.md).


**Reveal web —19/10/2026:** prohibida la cobertura opaca/crema antes del stagger.
Usar StaggerReveal compartido para grupos generales; login/onboarding conservan
sus parámetros de useStaggerReveal. Sin .reveal ni arreglos por pantalla.
Cabeceras fuera del efecto, sin repetición por edición/refresh, movimiento
reducido inmediato y QR legible sin JS. Landing conserva clip-path aprobado.
[ADR-075](decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md).

Estado: norma para el desarrollo web. Aprobada por el usuario el 18 de octubre
de 2026, America/Lima, tomando la landing terminada como referencia.
Consolidada el 19/10/2026 con los fondos, stagger del login, toast y controles legales aprobados.

## 1. Referencia y alcance

Onboarding19/10: por instrucción expresa, /bienvenida toma la composición de
sader-panel con PNG y textos originales del móvil de Entre Huellas. Columna448px
con logo oficial y texto entre huellas en cabecera al inicio de página,
alineados al borde como landing, fuera de la columna de pasos y del stagger,
también en responsive.
Por corrección posterior del usuario, solo avanzar con Continuar/Comenzar:
sin botón Anterior ni tres puntos visibles; conservar anuncio accesible del paso.
Alineación a la izquierda, Inter local, título48px/600 y descripción18px/500;
por ampliación posterior solicitada, ilustración al ancho completo de columna
(hasta448px base en escritorio, ancho disponible en móvil), sin recorte ni
alterar PNG/proporción. Sustituye el límite anterior288px.
botón carbón mínimo48px con radio18px base, flecha20px. Es excepción local a la
fuente Arial y cápsula generales. Cuatro grupos de useStaggerReveal550ms/90ms,
offset56px, salida invertida antes de cambiar paso; sin .reveal/cobertura crema.
Mantener scroll con texto ampliado, movimiento reducido sin esperas y guardado
con shimmer visible/error/reintento. Sin copiar configuración de apariencia.
[ADR-074](decisiones/074-onboarding-web-referencia-sader-y-mobile.md).

Acceso general19/10: /iniciar-sesion conduce a /bienvenida (tres pasos sin
Omitir hasta completar por cuenta) o /inicio. Inicio muestra datos reales de
cuenta y herramientas de gestión solo al confirmar permisos. Mantener navegación
de usuario separada de la tarea de revisión y retorno a Entre Huellas; ningún
enlace a funciones pendientes. Administradores/revisores también pueden usar las
funciones normales. [ADR-073](decisiones/073-acceso-general-web-y-gestion-por-permisos.md).

Por instrucción del19/10/2026, las rutas de navegación visibles se escriben en
español, minúsculas y guiones, sin tildes ni ñ. Seguir
[ADR-072](decisiones/072-rutas-web-en-espanol.md): al migrar, mantener
redirecciones desde rutas antiguas y parámetros necesarios del recorrido.
Raíz / y QR /c/:token conservados; endpoints internos, callbacks OAuth y
deep links mantienen sus contratos. Login y legales ya migrados; otros recorridos
aplican la regla al implementarse.

Por instrucción explícita del usuario del18/10/2026, la administración y
moderación son exclusivas de esta plataforma web. No hay equivalente
administrativo en Flutter. La denuncia móvil es una operación de usuario.
El acceso real de HU-14.3 se documenta en
[ADR-071](decisiones/071-moderacion-exclusiva-platform.md); no confundir una
pantalla de acceso con autorización, comprobada también en servidor y SQL.

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
La implementación vigente de acceso web separado y moderación se documenta en
[Acceso web](funcionalidades/acceso-web.md) y [Moderación](funcionalidades/moderacion-web.md);
el incremento actual entrega inicio de cuenta, sin declarar paridad completa de
funciones de usuario entre web y móvil.

## 2. Fuentes reales de la referencia

| Fuente | Qué consultar |
| --- | --- |
| [landing.css](../apps/platform/app/features/landing/presentation/styles/landing.css) | Valores, cascada final, variantes y media queries aprobadas. |
| [LandingPage.vue](../apps/platform/app/features/landing/presentation/screens/LandingPage.vue) | Composición, jerarquía, textos, anclas y FAQ. |
| [BackgroundGlowOrb.vue](../apps/platform/app/components/BackgroundGlowOrb.vue) | Resplandor compartido, intensidades, colores y movimiento reducido. |
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
| Texto secundario de landing | `#787774` (`--muted`); revisar contraste por superficie. |
| Azul de marca | `#3C537B` (`--brand-blue`). |
| Acento azul | `#2C87CE` (`--brand-accent`). |
| Celeste | `#B5D5E9` (`--brand-sky`). |
| Superficie azul tenue | `#EDF5FA` (`--brand-mist`). |
| Paneles de landing | `#F3F2EE` (`.panel`), incluido «Una comunidad con un propósito». |
| Otras superficies de contenido | Blanco o fondos suaves según el recorrido. |

### Fondos vigentes de landing

Distinguir el fondo exterior de la página, el fondo detrás del carrusel y los
paneles de contenido. Mantener estas capas al ajustar colores:

| Capa | Composición vigente |
| --- | --- |
| Fondo general exterior | Blanco con radiales celestes suaves y transición vertical al cream del footer. |
| Fondo detrás del carrusel de mascotas | Blanco predominante con cream tenue y bordes difuminados, sobre el fondo general animado. |
| Panel «Una comunidad con un propósito» | `#F3F2EE`, igual que la base `.panel`. |
| Footer | Conserva `--cream: #FFFBEF` mediante la transición del fondo general; el resplandor se desvanece antes del pie. |

El fondo general de `.landing-page` combina dos radiales:
`ellipse at 0% 12%, #dceaffd9 0, transparent 45%` y
`ellipse at 100% 40%, #e7f3ffb3 0, transparent 45%`, sobre
`linear-gradient(180deg, #fafdff 0%, #ffffff 65%, #fffdf7 84%, var(--cream) 100%)`.
Sustituye el antiguo radial crema `#fffdf8` sobre `--cream`.

El fondo exterior del carrusel corresponde a `.character-strip::before`:
`linear-gradient(180deg, #ffffff00 0%, #fffffff2 16%, #fffdf8f5 55%, #fffbefe6 84%, #fffbef00 100%)`.
La capa es absoluta, decorativa y sin eventos, con aislamiento local y orden de
capas detrás de tarjetas y control de pausa. Conservar tamaños, espacios,
colores de las tarjetas y movimiento de mascotas al ajustar este fondo.
La aclaración del usuario sitúa el blanco/cream en esta zona exterior;
el panel de propósito conserva su color original `#F3F2EE`.

Usar superficies claras, texto oscuro y separación por espacio, radios y color;
evitar bloques de azul saturado o sombras pesadas. Azul de marca y azul de acción
son usos distintos: el botón principal tiene degradado, no fondo plano `#3C537B`.

La landing conserva variantes por sección:

- Hero: aurora multicolor verde/lima/celeste/lavanda; mascotas pequeñas
  originales y valores blancos.
- Oportunidad: conservar el retoque local del usuario en escritorio,
  `linear-gradient(#80cbfa 0%, #a3e2f0 46%, #ccd2e39e 100%)`, y su variante
  responsive vigente en CSS. Comunidad y colaboración conservan sus variantes.
- Cierre «Una huella tuya»: aurora azul/celeste/lavanda.
- Pasos 01–04: numeración `#171918`, sin los pines CSS retirados en 02/03.

Estas composiciones sirven para presentación institucional. En formularios,
tablas y lectura de datos usar fondos tranquilos que mantengan la jerarquía.
Lima es un acento de marca; no significa éxito por sí mismo. Los colores de
error/éxito deben tener semántica explícita, icono o texto accesible y contraste
verificado. La landing informativa no define una paleta completa de estados.

## 4. Tipografía y jerarquía

La familia general aprobada es `Arial, Helvetica, sans-serif`. Por instrucción
posterior del18/10/2026, únicamente /terms y /privacy usan DM Sans local,
como sader-panel; la excepción incluye títulos, cuerpo y metadatos legales.
Por instrucción posterior del19/10/2026, /bienvenida usa Inter variable local
como el onboarding de sader-panel, limitado a esa ruta (ADR-074).
Login, landing y moderación conservan la familia general. No añadir otra fuente
como parte de una nueva pantalla sin registrar el cambio de referencia.
Por instrucción explícita posterior del18/10/2026, solo la frase del detalle
decorativo superpuesto al footer usa Kalam Regular local (SIL OFL); la referencia
manuscrita no se extiende a títulos, formularios ni otros textos. Véase ADR-063.

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

La página /iniciar-sesion conserva la composición del formulario aprobada:
sin tarjeta exterior, campos suaves con iconos y control Mostrar/Ocultar
contraseña. Por ADR-077, la marca se comparte con landing en cabecera superior,
fuera del formulario; ya no se usa la marca grande en dos líneas.
Mantiene Arial; no adopta la fuente de sader-panel ni la de Flutter.
WebShell minimal retira cabecera/footer institucionales duplicados en ese
recorrido y mantiene el salto al contenido. Columna de hasta488px incluyendo
padding lateral24px, centrada verticalmente y con scroll natural en poca altura.
LoginInput usa #F5F5F7/radio22px/alto mínimo76px, etiqueta flotante persistente y
control de visibilidad48px. Estados/foco/invalid/toast/shimmer siguen las reglas
globales y el resplandor soft permanece. Botón carbón es variante exclusiva de
login. No extender esta composición a páginas operativas automáticamente.

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
Excepción expresa19/10: onboarding /bienvenida usa el botón de la referencia
sader-panel, radio calc(.625rem + 8px),18px a tamaño base, según ADR-074.

| Variante | Apariencia aprobada |
| --- | --- |
| Principal de login | Por solicitud posterior del18/10: carbón `#111111`, texto blanco, sin sombra ni degradado; conserva cápsula y shimmer. |
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

### Resplandor ambiental compartido

Reutilizar [BackgroundGlowOrb.vue](../apps/platform/app/components/BackgroundGlowOrb.vue)
desde componentes compartidos. Contiene dos orbes difuminados, halo y grano SVG
local [glow-grain.svg](../apps/platform/public/images/glow-grain.svg).

| Configuración | Valor vigente |
| --- | --- |
| Prop `intensity` | `soft` = 0.42, `medium` = 0.5 (predeterminado), `strong` = 0.62. |
| Colores por tokens CSS | `--glow-color`: `#9BC6F5`; `--glow-secondary`: `#D6E8FF`. |
| Movimiento | Orbe principal 17s, secundario 11s y halo 16s; `ease-in-out infinite`. |
| Aparición | Opacidad durante 1.3s, retraso 300ms. |
| Integración de landing | Una instancia `intensity="soft"` detrás del contenido. |

El consumidor aporta posición relativa y orden de capas; la landing usa
`isolation: isolate` y `z-index: -1` para el resplandor. Su viewport interno es
sticky con altura `100svh`, de modo que acompaña el scroll. La máscara exclusiva
de landing `linear-gradient(#000 0% 70%, transparent 92%)` extingue la luz antes
del footer. El componente compartido mantiene esta decisión fuera de su lógica.

Decorativo con `aria-hidden="true"` y `pointer-events: none`; no debe interceptar
clics, agregar foco ni generar desbordamientos. Colores desde CSS e intensidad
por clases, sin estilos inline, recursos externos ni excepciones CSP. Con
movimiento reducido queda estático y visible, sin aparición animada.

Al usarlo en otro recorrido, importar el componente compartido y definir sus
tokens/capas en el consumidor. Su integración no lo activa globalmente; elegir
intensidad y ubicación según la legibilidad de cada tarea.

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
- Fondos: carrusel blanco/cream, panel de propósito #F3F2EE y footer cream;
  resplandor detrás del contenido, sin interceptar acciones, activo con movimiento
  normal y estático/visible con movimiento reducido.
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

## Acceso social y consulta inicial del login —18/10/2026

Por solicitud posterior, /login muestra siempre su formulario local; comprobar
sesión no lo sustituye por un skeleton ni remonta su reveal. Mientras consulta,
controles deshabilitados y aria-busy, sin shimmer por deshabilitación.
La carga de datos remotos en otras pantallas conserva skeleton. Se retira el
texto de cuentas autorizadas. Google/Facebook usan SocialSignInButton reutilizado,
iconos locales, separador «o continúa con», cápsula blanca/borde suave60px y
Arial1rem; texto ampliado puede ocupar varias líneas sin recorte. Shimmer de
proveedor solo durante su petición, bloqueo de dobles envíos y toast compartido
para errores/cancelación. No mostrar códigos ni mensajes del proveedor en UI.

## Icono, orbe y enlaces legales del acceso —18/10/2026

Por corrección posterior del usuario, /login usa la entrada de sader-panel:
opacidad0→1, blur18→0px y desplazamiento desde arriba28px, duración850ms, curva
cubic-bezier(.22,1,.36,1) y separación90ms. Grupos: icono, nombre, título, lema,
formulario y enlaces legales. La implementación vigente es el composable compartido
useStaggerReveal, port del hook de sader-panel: transiciones (sin keyframes),
doble requestAnimationFrame y will-change persistente. Conservar opciones de
orden/dirección, activación y limpieza; índices explícitos en el login. Aplicar
estilos con vStaggerReveal/CSSOM para respetar CSP; clase SSR oculta equivalente.
Entrada del icono en wrapper exterior al hover. No usa .reveal ni su cobertura crema: esa capa
producía el destello amarillo al recargar. Esta indicación sustituye la entrada
previa del icono700ms/12px/escala y el cover del login exclusivamente; las demás
pantallas conservan sus efectos. La cabecera entra una vez y permanece estable
al editar/comprobar sesión. Hover/foco del icono1.05 en300ms, separado de entrada.
Movimiento reducido estático, sin escala interactiva. Tipografía Arial conservada.

AmbientPageShell comparte fondo blanco/celeste→cream y BackgroundGlowOrb; login
usa strong0.62 y documentos legales medium0.5 fijo al viewport. La landing conserva su composición.
El resplandor sigue siendo decorativo, sin eventos ni cambios de foco.

/login muestra enlaces a /terms y /privacy después del formulario. Documentos
legibles en SSR, barra superior dentro del documento, retorno glass y contacto
real; textos ampliados ajustan línea sin ocultar overflow ni reducir tamaño.
Contenido permanente del servicio, sin rótulos de MVP ni datos legales inventados.

## Referencia legal sader-panel —corrección18/10/2026

/terms y /privacy usan su composición de lectura: documento máximo896px,
barra superior alineada (retorno y enlace cruzado), separación inferior24px/
margen32px, título centrado con degradado oscuro/gris y fila de metadatos con
iconos de reloj/anuncio16px. Los controles de la barra usan estas medidas vigentes:

| Control | Medidas y estilo |
| --- | --- |
| Retorno izquierdo | Círculo glass de36×36px; chevrón vectorial16px; blur22px. En flujo dentro de la barra. |
| Enlace derecho al otro documento | Alto mínimo36px; padding vertical8px/horizontal12px; gap8px; flecha16px. |
| Radio del enlace derecho | calc(.625rem + 8px), equivalente a rounded-2xl de sader-panel:18px a tamaño base. |
| Texto del enlace derecho | DM Sans14px, peso500, interlineado20px; colores de Entre Huellas. |

El enlace puede crecer y ajustar líneas con texto ampliado; no fijar su altura
ni recortar texto. El retorno conserva diseño circular glass, foco, tooltip y
navegación al login. Ambos cambios son locales a LegalPage: el componente
GlassNavigationButton mantiene52px/chevrón28px en los demás recorridos.
Sin logo/descripción/índice adicional. Por corrección posterior del usuario,
DM Sans local solo en estas dos páginas; escala equivalente al
CSS real de la referencia: h1 45px/h2 32px/cuerpo16px con interlineado24px,
metadatos14px y footer12px. Rem conserva crecimiento con texto ampliado.

Scroll independiente del contenido en100svh; orbe medium0.5 fijo, sin máscara
vertical que lo apague al desplazarse. Capa de lectura backdrop-blur10px con
bordes difuminados. Sin cobertura crema ni entrada del artículo en estas páginas,
por solicitud de igualar la referencia estática. Movimiento reducido deja
el resplandor visible/estático. Login y landing conservan sus efectos vigentes.

## Chevrón vectorial e iconos de metadatos —18/10/2026

El retorno web usa AppIcon con chevron_left de Material Symbols Rounded
(FILL1,24px ópticos) renderizado a28px; nunca un carácter tipográfico.
GlassNavigationButton conserva círculo52px/foco/tooltip/área táctil y añade
gradiente translúcido/reflejos interiores y blur22px como el móvil. La posición
de la barra legal conserva su override en flujo y variante compacta36px/icono16px;
los demás usos siguen flotantes con52px/icono28px.

Reloj/anuncio: schedule/campaign de Material Symbols Outlined FILL1,
óptica20 y tamaño16px, igual que sader-panel. Trazados SVG locales oficiales,
sin peticiones ni fuente de iconos externa. DM Sans variable local con licencia
OFL y preload solo en páginas legales; no extender esa familia a todo el sitio.
Ver ASSETS_UI de platform para procedencia y licencias.

## Toast web alineado con móvil —18/10/2026

Por solicitud del usuario, TopToast compartido reproduce ConfirmationToastHost
móvil: cápsula #F5F5F7 al90%, borde blanco70%, radio28px, blur18px y sombra
#24282A al10% desplazada6px/blur20px. Ancho ajustado al mensaje hasta360px,
márgenes laterales24px y safe-area superior+12px, mínimo48px, padding16/8px.
Icono Material Rounded oficial20px dentro de círculo neutro32px; error_outline
en #B53F48 para error y check #111111 para confirmación. Texto14px, peso400 (normal, sin negrita) y fuente heredada de la página.
La ausencia de negrita es una corrección explícita del usuario y prevalece
sobre el peso600 del toast móvil de referencia. Sin X: tocar el aviso o activar su botón mediante
teclado lo cierra. Reintentar sigue siendo acción independiente, cierra primero
y ejecuta su callback. Entrada fade lineal y slide easeOutCubic de180ms;
movimiento reducido estático. Mensajes extensos/texto ampliado pueden hacer
scroll vertical dentro del límite30svh/220px, sin recorte de contenido.

Conserva API show, roles alert/status, expiración web6500ms y limpieza al
desmontar; no se altera autenticación, stagger, orbe ni código Flutter.
La adaptación se comparte con los recorridos que ya consumen TopToast.
