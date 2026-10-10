# Diseño de la interfaz: implementación y revisión

La norma obligatoria es [REGLAS_UI_UX.md](REGLAS_UI_UX.md). Su referencia son las pantallas actuales de Login, Crear cuenta, Recuperar contraseña, Revisa tu correo, Nueva contraseña y Contraseña actualizada. Este documento es un índice de implementación; no mantiene otra paleta ni reglas diferentes. Sustituye las propuestas antiguas de superficies coloreadas y la UI retirada de Inicio.

## Componentes de referencia

Rutas relativas a `flutter_application_entrehuellas/lib`:

| Responsabilidad | Fuente |
| --- | --- |
| Layout, cabecera y scroll | `core/presentation/widgets/app_page_layout.dart` |
| Acción principal | `core/presentation/widgets/primary_action_button_style.dart` |
| Marca | `core/presentation/widgets/brand_mark.dart`, `brand_wordmark.dart` |
| Arranque horizontal con resorte | `core/presentation/widgets/startup_reveal.dart` |
| Cover y cambios de etapa | `core/presentation/widgets/cover_reveal.dart` |
| Stagger compartido | `core/presentation/widgets/stagger_reveal.dart` |
| Carga y atenuación | `core/presentation/widgets/loading_shimmer.dart` |
| Error de campo | `core/presentation/widgets/shake_field.dart` |
| Decoración de inputs de acceso | `features/auth/presentation/widgets/auth_input_decoration.dart` |
| Correo y OTP | `features/auth/presentation/widgets/email_code_confirmation.dart`, `email_code_input.dart` |
| Tema general | `core/theme/app_theme.dart` |

AuthPageLayout y authPrimaryButtonStyle delegan en las versiones compartidas de core. Mantienen geometría del flujo aprobado. No importar widgets de Auth desde otro módulo: extraer la responsabilidad común cuando corresponda.

## Referencias renderizadas

Desde la carpeta Flutter:

```powershell
flutter test --no-pub tool/capture_ui_preview.dart
```

Genera en `build/ui-preview` login, registro, solicitud de código, confirmaciones OTP, nueva contraseña, éxito, arranque y fases de cover/stagger/shimmer. Viewport normal 390 × 844, fuentes reales y repositorios sustituidos. Variantes pequeñas incluyen 320 × 350 con texto escala 2. Inicio provisional tiene `home.png` y `home_small.png`; conserva solo bienvenida y cierre de sesión hasta diseñar el módulo real.

Revisar capturas finales e intermedias, controles accesibles con teclado/scroll, estados de error y carga. Las capturas no prueban correo/Auth remoto ni fluidez en Android. Resultados y pendientes se registran en [ESTADO.md](ESTADO.md).

## Comportamientos conservados

El onboarding mantiene tres etapas después del primer ingreso y persistencia por cuenta según [ADR-004](decisiones/004-onboarding-por-cuenta.md), sin Omitir. Se conserva PageView y reveal textual, mascotas completas, margen de ilustración 12, alto proporcional .68 limitado a 180–460, indicadores 12/margen 5 y Continuar/Comenzar de radio 26/alto mínimo 68. Este diseño no sustituye la referencia normativa de acceso ni autoriza a copiarlo como otro estilo general.

Splash Android conserva fondo blanco y PNG 3D de marca. Su variante API 31+ usa margen proporcional de 33.3333% por lado para respetar la máscara. Debe verificarse tras recompilar/reinstalar con arranque frío; Hot Restart no actualiza recursos nativos. El resorte horizontal y el cover/stagger de Flutter se revisan tras Hot Restart.

## Inicio con cápsula liquid glass

Diseño autorizado el 8 de octubre de 2026: `features/home/presentation/widgets/liquid_navigation.dart` implementa superficie translúcida con blur, cápsula de cuatro destinos y acción Reportar separada. `home_content.dart` compone cabecera de contenido, tarjeta destacada, acciones y sección cercana; los módulos pendientes se identifican expresamente sin datos de ejemplo. `home_view_model.dart` controla selección y salida mediante el caso de uso existente de dominio, sin importar presentación de Auth.

QA añade `home_report.png`, `home_small.png` y `home_profile_small.png`. El cierre de sesión pasó a Perfil. La cabecera puede desplazarse con el contenido en pantallas pequeñas; queda fuera del efecto de cambio de sección. Esta entrega es el diseño navegable de Inicio, no la implementación de HU-02–HU-13 ni una prueba de sus servicios.

### Ajuste de navegación y paleta, 8 de octubre de 2026

La cápsula queda solo con iconos, manteniendo nombres accesibles/tooltip/selección semántica. Selección carbón #111111, icono blanco e inactivos #6E6E73, según los componentes reales de login. Acciones de Inicio y tema Material usan la paleta neutra del mockup. GlassSurface reduce la opacidad, aumenta blur a 22 y pinta doble borde de reflejo direccional en blanco/gris, con sombras neutras. No utiliza un shader de refracción física. Se conserva el panel Reportar, las cuatro secciones y la salida real.

### Nueve puntos e indicador deslizante

Ajuste aprobado el 8 de octubre: acción Reportar con puntos blancos 3 × 3 sobre círculo sólido #111111, sin GlassSurface. La cápsula conserva glass y usa un único indicador deslizante, interpolado en 320 ms, con retarget desde posición actual y movimiento reducido inmediato. Capturas adicionales: home_navigation_slide y home_explore. ADR-006 y REGLAS_UI_UX registran que esta animación local convive con cover/stagger del contenido.

Último ajuste de selección: InkWell de destinos usa NoSplash y overlay transparente para eliminar el destello de Material durante el deslizamiento. Se conserva el glass estático y el contraste del icono activo.

Cabecera de Inicio: BrandWordmark compartido con iconSize 46/textSize 22, dos líneas y sin lema. Sustituye la composición manual con nombre en una línea y subtítulo; conserva semántica continua de marca.

## Perfil de cuenta

HU-01.7 / RF-01, issue #23: pestaña Perfil con nombre visible y ciudad opcionales, validación, guardar/descartar y cierre de sesión existente. Usa los componentes aprobados de acceso. `core/presentation/widgets/app_input_decoration.dart` contiene la implementación compartida; `authInputDecoration` delega sin cambiar geometría/estados de login. ProfileEditor consume únicamente su ViewModel; router compone el formulario en Home.

QA incorpora profile, profile_loading, profile_load_error, profile_saving, profile_error, profile_saved, profile_small, profile_fields_small y profile_actions_small. Los datos de esos renders son fixtures exclusivas de pruebas; la app consulta el repositorio real inyectado. Cover/stagger sigue en el shell al entrar en la sección, sin repetirlo por edición, guardado o error.

Ajuste de Perfil: retirados encabezados redundantes y texto de instrucciones permanente; conserva un título Perfil y los dos campos. Cerrar sesión usa superficie roja tenue y texto de error aprobado, dimensiones compactas (mínimo 48, fuente 14) y carga compartida. Guardar permanece como acción principal; sin cambios de persistencia/permisos.

## Toast superior de confirmación

ConfirmationToastHost en core sustituye el texto permanente de éxito de Perfil por «Cambios guardados» flotante sobre la cabecera. Aviso compacto carbón/blanco con icono de éxito y cierre; expira sin modificar layout. Sin paquetes externos. El formulario conserva errores contextuales. Su lifecycle, accesibilidad y alcance están en ADR-007; entrada local independiente de cover/stagger del contenido. QA: profile_saved muestra el aviso; profile normal no lo muestra.

Toast revisado a estética iOS por petición del usuario: cápsula clara de ancho ajustado al mensaje, icono oscuro en medallón neutro y sin X. Cierre al tocar y acción accesible; fondo difuminado, borde claro y sombra leve. Mantiene comportamiento de confirmación y ciclo de vida. Revisión visual en profile_saved y profile_toast_small.

## Perfil desde cabecera

Perfil se abre mediante avatar circular de cabecera, logo/campana conservados. Home tiene tres destinos inferiores; ProfileScreen mantiene campos, toast y salida danger en una ruta superpuesta con cierre X/Atrás, sin barra inferior. OriginPageTransition reutilizado desde bounds de avatar; _ProfileEntrance espera completar apertura antes de stagger. Renders nuevos: profile_origin_start y profile_origin_middle; home/profile y variantes pequeñas actualizados. Avatar muestra foto privada de la cuenta, respaldo HTTPS de Google o iniciales reales. Galería/subida incorporadas mediante ADR-008 por solicitud posterior.

ProfilePhotoEditor agrupa avatar de 72, acción de cámara y Añadir/Cambiar foto. LoadingShimmer conserva etiqueta; fallo junto a la acción y reintento con bytes retenidos. Recuperación de selección ofrece Guardar foto recuperada/Descartar antes de enviar. ProfileEditor presenta Correo electrónico como SelectableText en superficie neutra con icono, sin TextField ni comando de escritura. Nombre/ciudad y salida danger conservan componentes existentes. Renders normal/pequeño con texto 2 revisados; no se acredita fluidez de galería nativa ni subida real con capturas de harness.

Retirados título/promesa de Inicio y su espaciado para priorizar contenido útil visible. El hero existente, acciones y Cerca de ti conservan composición y operaciones; timeline de entrada ajustado a los bloques reales.

## Ajuste autorizado de foto, ADR-009

Por nueva solicitud explícita del usuario, el avatar es el único acceso habitual al selector/reintento: retirados Añadir/Cambiar foto y error permanente. El toast compartido admite icono de error danger suave para fallos de foto, con el mismo ciclo de vida y sin generalizar a otros errores. La confirmación excepcional de selección recuperada se conserva. Ver ADR-009, que amplía el alcance de feedback de ADR-007/005.

## Registro y ficha de mascotas

Componentes en features/pets: PetsSection (lista/consulta vacía/error), PetScreenShell (cabecera persistente y cover/stagger), PetEditorScreen (seis grupos con inputs compartidos, selectores adaptables, error/shake y LoadingShimmer) y PetDetailScreen (campos reales y edición). Composición desde router evita acoplar Home a presentation de mascotas. Sin control de fotografías hasta HU-04.

QA reproducible: flutter test --no-pub test/pets_navigation_test.dart --concurrency=1 --dart-define=CAPTURE_PETS=true. Capturas pets_empty/form/species/detail/error/list en build/ui-preview, normal y 320x350 con texto 2. Repositorio de prueba solo en harness; la app consulta Supabase y distingue error de vacío. No acredita sesión/reinicio Android ni despliegue remoto.

## AppSelectField: selección acorde a los inputs

Core/presentation/widgets/app_select_field.dart implementa campo controlado reutilizando decoración compartida y panel inferior de opciones propio. Especie y Sexo en PetEditorScreen consumen el mismo componente; callback solo llama al ViewModel. AppSelectOption envuelve incluso valores null para diferenciar desconocido de cancelación. Sin SDK ni reglas de dominio en el componente.

Panel blanco sin elevación/tinte, radio superior 28; filas neutras de radio 18, estado activo carbón/check, iconos decorativos y etiquetas accesibles. Cabecera fuera de cover/stagger; cuerpo desplazable, texto ampliado y movimiento reducido conservados. Campo y flecha conservan dimensiones de input y foco/error. QA añade pets_options_normal/small; pruebas de selector comprueban cancelación, desconocido y bloqueo, junto al recorrido completo de mascotas.

## Placeholders de carga, ADR-011

PetSkeleton (widgets de pets) reutiliza LoadingShimmer con layouts de tarjetas/detalle/formulario. SkeletonFormFields en core comparte geometría escalable entre editor de mascotas y Perfil; no contiene operaciones ni datos simulados. PetRefreshProgress superpone línea de 2 píxeles sin alterar posiciones; TickerMode respeta movimiento reducido. Widgets diferencian loading inicial, refresh explícito con valor previo de la misma cuenta, error y vacío confirmado. No existe texto visible Cargando/Preparando ni spinner circular.

QA: pets_loading/detail_loading/editor_loading normal/pequeño en el harness de navegación con consultas pendientes; profile_loading en el harness general. Pet loading tests comprueban skeleton -> error -> reintento -> vacío confirmado y refresh con tarjetas que se ocultan al cambiar cuenta. La semántica de carga permanece accesible aunque no haya texto visible. Referencia de patrón: https://docs.flutter.dev/cookbook/effects/shimmer-loading.

## Ficha ampliada y fotos privadas, ADR-012

PetScreenShell coloca retorno fijo en SafeArea superior y contenido desplazable alineado arriba. PetSizeSelector ofrece tres chips neutros en fila horizontal desplazable, selección de borde carbón y etiqueta accesible; tocar el activo limpia tamaño. Campo Tipo de mascota aparece solo para Otra especie y reutiliza input/error existentes. PetPhotoGallery ofrece miniaturas de 112 píxeles/radio 22 y acción de añadir foto, sin botón duplicado ni datos simulados; hasta tres fotos, retirada accesible, shimmer real y errores contextuales. Ficha muestra fotos confirmadas y listado primera foto como portada.

QA: capturas pets_form/species/detail/editor_loading normal y 320x350 con texto 2; pruebas verifican retorno arriba, cancelación/selección/retirada, tipo/tamaño y persistencia. Selector nativo/fluidez Android pendientes de build funcional, no acreditados por capturas de widgets.

## Paleta del mockup aprobada, 9 de octubre de 2026

Referencia cromática: `mockups/Entre Huellas_ personajes 3D premium.png`. Fondo #FFFFFF, texto/acciones #111111, superficie #F5F5F7, texto secundario #6E6E73 y separadores #E5E5EA. AppTheme declara todos los roles Material mediante ColorScheme.light, incluidas superficies, contenedores y colores fijos; sin generación desde una semilla. AppColors conserva solo los tokens neutros y el error contextual de ADR-005. Componentes de acceso, Perfil, Inicio y mascotas alineados con estos valores.

PetSizeSelector reutiliza AppColors y desactiva surfaceTintColor para que el chip seleccionado conserve su superficie neutra. El borde y la semántica comunican selección. QA añade pets_size_selected y pets_edit_size en tamaños normal y pequeño con texto ampliado; el harness conserva selección, deselección y persistencia existentes.

## Texto y selección con etiqueta interior

AppFieldSurface contiene el marco, foco, error, etiqueta interior y espacio opcional del icono. AppTextField incorpora TextField nativo, controlador recibido, teclado/autofill, líneas y callbacks; posee y libera su FocusNode. AppSelectField reutiliza el marco y conserva el panel de selección, cancelación y valor null explícito. Ningún componente obtiene repositorios ni controla reglas de producto.

PetEditorScreen y ProfileEditor adoptan los campos; etiquetas externas retiradas de inputs/selectores. Correo de Perfil mantiene SelectableText dentro del mismo marco, sin comando de edición. Uso: AppTextField(label: 'Nombre', controller: controller); añadir icon: Icons.person_outline_rounded cuando se necesite. Para varias líneas, indicar minLines/maxLines. AppSelectField admite omitir icon y hint.

QA: flutter test --no-pub test/app_text_field_test.dart --concurrency=1 --dart-define=CAPTURE_FIELDS=true genera fields_empty/filled/selected/error_normal/small. Comprueba etiqueta accesible, escritura, multilinea, limpieza por controlador, bloqueo, error, selección sin icono y liberación al desmontar. Harness de mascotas y capturas generales verifican integración normal y 320x350 con texto 2. Datos de las capturas pertenecen exclusivamente a pruebas.

## Entrada única al resolver skeleton

PetScreenShell mantiene AuthStageTransition con etapa constante y usa ContentReveal: la línea de tiempo no se recrea al pasar carga -> ficha/formulario/error. ContentReveal completa el StaggerReveal al resolver una carga observada; contenido disponible desde el montaje conserva su entrada. Perfil reutiliza ContentReveal y mantiene la expansión de ruta. PetsSection recuerda haber mostrado skeleton y desactiva el StaggerRevealItem heredado del Home para el resultado. Refresh, reintento y cambio de cuenta conservan responsabilidades y privacidad previas.

content_reveal_test verifica respuestas rápidas durante el cover y lentas después de la entrada, datos/vacío/error inmediatamente opacos e interactivos, ausencia de nueva cortina, reintento y entrada inicial de contenido disponible con movimiento reducido. No se usan retrasos de producto para ajustar animación.

### Corrección de skeleton que aparece, se oculta y reaparece

AuthStageTransition admite enabled para omitir/cancelar la cortina sobre cargas; PetScreenShell lo desactiva mientras espera datos. ContentReveal completa la línea de tiempo desde que observa skeleton, no solo al resolverlo. Home desactiva cover/stagger en Mis mascotas. Así no se tapa otra vez el placeholder que ya se mostró.

PetDetailViewModel y PetEditorViewModel mantienen la carga de pantalla hasta completar en paralelo ReadPet e inicialización de fotos. PetPhotosViewModel.ensureInitialized comparte el Future inicial dentro del ciclo de cuenta/mascota; PetPhotoGallery lo reutiliza al montarse, conservando initialize para reintentos explícitos. Sin APIs/SDK en widgets, datos ficticios, demoras o cachés globales.

pet_screen_loading_test observa 20 frames con consulta pendiente, completa metadatos antes de fotos y comprueba que conserva el mismo elemento skeleton sin cortina, antes de mostrar una única galería sin segunda consulta. Incluye ficha/edición normal y pequeña con texto 2. content_reveal_test ahora exige skeleton completamente visible desde el montaje.

## Apertura de Registrar mascota desde origen

PetsSection obtiene bounds del botón mediante Builder/RenderBox y envía Rect en extra a /home/pets/new. Router reutiliza OriginPageTransition en CustomTransitionPage, con las mismas duraciones de Crear cuenta y Perfil. PetScreenShell mantiene la continuidad de skeleton de ADR-011. PetEditorScreen regresa con pop al cancelar y conserva navegación a ficha tras éxito.

Harness de mascotas verifica rectángulo del botón, apertura, contracción/cierre y reapertura sin perder la sección; capturas pets_register_origin_start/middle_normal/small muestran fases, junto al formulario final. Prueba compartida de OriginPageTransition cubre movimiento reducido.

## Botones equilibrados y fallo de eliminación en toast

PetDeletionDialog comparte geometría de ambas acciones mediante _DeletionActions: ancho/alto iguales, 48 mínimo, padding 8, radio 18 y fuente 14. LayoutBuilder/TextPainter comprueban si caben en fila y calculan altura común al apilar con texto ampliado. No heredar dimensiones distintas de FilledButton y OutlinedButton.

PetsSection retira los bloques de error bajo cada fila y envía error/éxito al ConfirmationToastHost. noticeId de PetDeletionState identifica cada resultado; el host permite acción opcional y anuncios repetidos. Conflicto ofrece Actualizar lista dentro del aviso. ADR-013 registra la excepción autorizada. Harness de mascotas genera pets_delete_confirmation y pets_delete_error_toast normal/pequeño; prueba de toast verifica repetición, acción, dismiss y disposición.

_DeletionActions ahora calcula ancho compacto desde la etiqueta más larga, usa padding 8/mínimo 48 y Align.bottomRight. Fila de ancho mínimo o columna alineada a la derecha con texto ampliado. Cancelar y Eliminar mantienen igualdad de tamaño, fuente y radio. Prueba de navegación comprueba tamaño y borde derecho del botón frente al grupo.

## Registro minimalista en Mis mascotas

PetRegistrationButton reúne variantes normal/compacta y captura del origen para /home/pets/new. PetsSection compone _PetsHeader con + Mascota solo si hay datos no vacíos; _PetsEmptyState ofrece huella mayor y Registrar mascota debajo del mensaje confirmado. Cabecera adapta fila/columna manteniendo acción derecha con texto ampliado. Fuente/colores/componentes compartidos conservados; no añade llamadas de producto a widgets.

Harness de mascotas verifica botón debajo de huella en vacío, ausencia de Registrar mascota ancho en listado, + Mascota en borde derecho, apertura desde ambos orígenes, cancelación/reapertura y persistencia. Capturas pets_empty/list/add_compact normal y pequeña con texto2. Renders siguen usando fixtures de pruebas y no acreditan Android remoto.

## Swipe continuo de eliminación

SwipePetCard usa AnimationController.unbounded con desplazamiento en píxeles: limitado al70% del ancho a la izquierda por corrección posterior, retorno a0 al soltar. Color rojo interpolado con recorrido y contentBuilder entrega foreground/secondary a textos/iconos conservando fotos. Retira el ClipRRect que encerraba toda la acción y el panel fijo Eliminar; el Material de la tarjeta conserva radio22 y recorte de su propio contenido.

onDelete ahora devuelve Future para bloquear duplicados hasta cerrar modal/terminar operación. Se espera endOfFrame tras el retorno para que el modal nunca cubra la tarjeta todavía desplazada. Listener distingue cancelación real del puntero; gesto cancelado y desmontaje no producen confirmación. Se retiran long press y CustomSemanticsAction de eliminación por petición de interacción exclusiva mediante swipe izquierdo; se conservan busy/disabled y LoadingShimmer durante borrado real.

swipe_pet_card_test verifica seguimiento, rojo progresivo, límite70% del ancho, retorno antes del callback, gesto corto/cancelado, bloqueo/duplicados, pulsación larga sin confirmación, disposición y movimiento reducido. Harness de mascotas captura swipe_partial/swipe durante drag y delete_confirmation después de retornar; confirmación/cancelación/error/reintento siguen pasando por ViewModel.

SwipePetCard añade ColorFiltered/BlendMode.srcATop sobre el contenido completo: texto/iconos/foto reciben tinte danger hasta32% según recorrido, por ajuste posterior del usuario. Filtro estable con intensidad0 en reposo, sin cambiar la estructura de widgets al iniciar/terminar el drag. Prueba de swipe incorpora Image e Icon, comprueba cobertura del filtro, variación y retorno al filtro inicial, y preserva el mismo elemento de imagen. Fondo interpola superficie a rojo contextual #C12F3D mediante easeOutCubic para intensificarse antes; texto/iconos interpolan sus colores originales a #FFE3E6 desde el inicio del recorrido con easeOutCubic compartido con fondo y filtro. Sustituye el salto negro/blanco basado en luminancia.

## Modal de eliminación con transformación de origen

SwipePetCard entrega Rect relativo al Navigator raíz después del frame de retorno. PetCardContent comparte la composición de foto/nombre/especie/icono entre listado y copia visual de origen. confirmPetDeletion usa showGeneralDialog y OriginDialogTransition, sin CoverReveal ni StaggerReveal. El layout final permanece estable; superficie interpola posición/tamaño/radio/color durante320ms. Copia original se desvanece hasta45%, destino aparece desde65% mediante originContentOpacity compartido con OriginPageTransition. Bloquear interacción/semántica del contenido hasta completar; movimiento reducido evita transformación. Cierre invierte la transición.

Cabecera del modal coloca cierre en su propia línea si texto ampliado deja poco ancho al título; scroll conserva acceso a todas las acciones en superficies pequeñas. Pruebas comprueban rectángulos de origen/destino, opacidad por etapas, reversa, interacción, movimiento reducido, límite del gesto y ausencia de cover/stagger en modal. Capturas delete_origin_start/middle y delete_confirmation complementan la revisión normal/pequeña.

PetCardContent compacta nombre y especie/texto secundario: gap2 (antes4), TextStyle.height1.2 para nombre y1.25 para secundario; padding vertical14 (antes20), horizontal20 conservado. Mantiene foto56 y altura flexible para texto ampliado/nombres largos. Reutilización en listado y copia de origen evita divergencia al abrir confirmación.

Corrección de retorno: OriginDialogTransition distingue cierre, omite copia de origen al contraerse y desvanece overlay en el último18% para dejar visible la tarjeta real. Material.animationDuration=Duration.zero evita una segunda animación de forma/color con retraso. La superficie alcanza el mismo Rect; origen real no se transforma. Prueba verifica cierre sin copia, overlay final invisible y ausencia de animación implícita. Color de texto/iconos y filtro del swipe cambian desde el inicio con easeOutCubic compartido con fondo, por corrección posterior del usuario.

PetRegistrationButton.compact ahora es FilledButton con CircleBorder, tamaño56, padding0, fondo ink e icono add_rounded blanco26 con semanticLabel Registrar mascota. Sin etiqueta Mascota visible; tooltip conservado. Key pet-add-compact identifica acción en harness sin depender de texto. Mantiene origen de navegación/cabecera derecha; variante de vacío conserva icono y etiqueta completa. SwipePetCard ya no registra pulsación larga ni acción semántica de eliminación, por instrucción de acceso exclusivo desde swipe izquierdo.

_PetsHeader conserva Row para carga/vacío/listado en ancho normal; SizedBox.square56 sustituye acción ausente y mantiene posición del título al aparecer el círculo. En layout apilado mantiene título primero. Harness compara desplazamiento del título respecto a PetsSection antes/después de registrar, independiente del scroll de navegación.

## Identidad y retorno de la ficha

PetDetailScreen elimina «Ficha de mascota» y presenta galería sobre el nombre (encabezado accesible de32). _PetIdentity observa PetPhotosViewModel para ocultar la huella al existir fotos; no accede a infraestructura. PetPhotoGallery admite tileSize; editor conserva112 y ficha usa ancho disponible limitado a160. PetSkeleton.detail sigue foto/nombre/datos. GlassSurface se extrae sin cambiar su acabado a core/presentation/widgets/glass_surface.dart; navegación y retorno circular de ficha lo reutilizan sin imports entre funcionalidades.

PetScreenShell con glassBack usa scroll a altura completa y retorno posicionado por encima, sin franja blanca superior. Padding inicial incluye inset superior +72; chevrón fijo en inset +4. Registrar/Editar comparten ahora el mismo layout flotante según ADR-015. PetSkeleton.detail reduce su foto a160. Prueba de carga/identidad verifica que al desplazar la galería ocupa el espacio detrás del retorno y el botón no se mueve.

_PetIdentity calcula un único tamaño en LayoutBuilder para foto y huella sustitutiva; ambos comparten dimensión hasta160 y separación inferior20. Icono decorativo excluido de semántica.

## Retorno común y selector de ancho completo

GlassNavigationButton en core reutiliza GlassSurface y centraliza círculo52/icono28/tooltip para volver/cerrar pantallas. PetScreenShell lo superpone en Stack para ficha, registro y edición; se elimina glassBack y la variante plana. ProfileScreen conserva cierre fijo sobre scroll; AppPageLayout reutiliza el mismo botón con X. ADR-015 registra la regla general.

PetSizeSelector usa Expanded en tres columnas con dos gaps8. ChoiceChip conserva callback/selección/borde neutro; label ocupa el ancho interior disponible. Con texto ampliado/ancho limitado dispone icono sobre texto adaptable. Harness de navegación verifica extremos y anchos iguales y genera size_selected en ambos tamaños.

## Confirmación de cambios sin guardar de mascotas

PetEditorState.hasUnsavedChanges distingue registro vacío de formulario modificado y compara edición con original; dirty conserva su semántica para guardado/validación. PetEditorScreen usa PopScope y el callback onBack de PetScreenShell para unificar salida por glass/sistema. Fotos pendientes también activan el guard. PetDiscardDialog reutiliza OriginDialogTransition con acciones reales y scroll. Confirmar salida limpia pending mediante PetPhotosViewModel.discardPending, sin tocar fotografías confirmadas, antes de cerrar. Rechazar salida conserva controladores/selecciones/fotos; guardado confirmado omite el aviso.

## Ficha abierta desde su tarjeta

PetsSection captura el Rect de la tarjeta pulsada mediante Builder/RenderBox y lo entrega como extra a /home/pets/:id. Router compone CustomTransitionPage con OriginPageTransition compartido, apertura320ms/cierre260ms y movimiento reducido. Sin Rect conserva NoTransitionPage y las semánticas previas de Pet guardado e inspect. No modifica consultas ni reinicia entradas al resolver skeleton. Harness de mascotas comprueba origen/retorno y captura detail_origin_start/middle/close normal y320×350 texto2.

## Editor de mascotas pulido — ADR-016

PetPhotoGallery editable usa tileSize calculado hasta160, igual que ficha; skeleton acompaña. Nombre/especie/tamaño/edad/rasgos obligatorios, sexo opcional/Macho inicial, especie sin valor con placeholder Seleccionar. AppFieldSurface/AppTextField/AppSelectField admiten invalid sin errorText; PetSizeSelector adapta borde danger sin overflow con texto ampliado. Rasgos o descripción muestra contador interno0/200 y UnicodeLengthLimitingFormatter coherente con dominio/SQL.

PetEditorState.invalidFields reúne fallos del dominio; ViewModel valida antes de enviar, incrementa errorId por intento y limpia solo el campo editado. Formulario y galería editable usan ConfirmationToastHost/ShakeField para errores, sin bloques de texto inferiores; aviso de conflicto conserva Ver ficha actual. PetPhotosState.errorId permite repetir fallos. ConfirmationToastHost maneja también estado confirmado al montar y limpia overlay/timer. Fotos de ficha mantienen feedback contextual. Nueva norma en ADR-016.

## Fotos pendientes hasta guardar — ADR-017

Quitar foto oculta la miniatura solo en el borrador editable; no borra el archivo al tocar X. Ficha mantiene fotos confirmadas. Añadir prepara vista previa local, y quitar una selección local la descarta sin llamadas remotas. Guardar contempla también retiradas sin cambios de campos; continuar conserva el borrador y Salir sin guardar restaura las fotografías confirmadas. Límite de tres aplicado al resultado previsto permite reemplazar. Feedback de guardado fallido conserva shake danger/toast de ADR-016 y pendientes para reintentar.

## Activas/Archivadas y acciones de ciclo de vida

PetsSection ofrece PetListFilter para Activas/Archivadas: cápsula gris #E5E5EA, dos segmentos iguales y un indicador carbón #111111 deslizante con texto blanco, sin check ni bordes individuales, según referencia explícita del usuario. Tipografía del tema14/600, padding6 y área táctil mínima48; letras ampliadas que no caben en fila se apilan dentro de la misma superficie, sin reducir ni truncar. Indicador y colores de ambas etiquetas comparten un único progreso TweenAnimationBuilder320ms/easeInOutCubic: color interpolado carbón/blanco según la posición, con reorientación desde el progreso vigente al cambiar de destino. Inmediato con movimiento reducido y orden RTL respetado. Mantiene consultas independientes y vacío específico de Archivadas. La ficha conserva Editar y añade acción secundaria Archivar/Restaurar con icono, etiqueta estable y LoadingShimmer durante la RPC. Archivo pide confirmación mediante OriginDialogTransition compartida, modal neutro desplazable y acciones que se ajustan al ancho; cancelar no escribe. Estado archivado comunica conservación de ficha/fotos. Errores contextuales bajo la acción, actualización ante conflicto y toast superior de éxito confirmado. Retorno glass y edición se deshabilitan durante la operación; PopScope protege Atrás. Eliminación por swipe conserva su feedback autorizado y explica restricciones por historial. Sin nueva animación de entrada al confirmar o refrescar.

## Continuidad visual del botón al registrar

PetRegistrationButton comparte _content entre botón y copia visual, conserva tipografía/padding/iconos y entrega OriginPageSource al router. OriginPageTransition recibe la identidad solo para pets/new y transforma carbón/radio/Rect; contenido de origen fijo y centrado, sin estiramiento, desaparece hasta45% y reaparece al contraer; destino desde65%. Otras rutas conservan parámetros anteriores. Capturas register_origin_start/middle/close/return y compact_origin_start/morph cubren las dos variantes normal y320×350 texto2; prueba compartida verifica identidad inicial/final, reversa, bloqueo y movimiento reducido.

## Zonas de interés — HU-02.1

Perfil abre `/home/interest-zones`, protegida por login/onboarding. Título32 carbón, margen24/max440, retorno GlassNavigationButton flotante con chevrón. Listado privado muestra vacío confirmado, radio, Editar/Eliminar con confirmación y Añadir zona; conserva datos con progreso fino al actualizar. Error inicial tiene Reintentar y nunca se representa como vacío.

Editor usa campo de nombre, mapa280 con selección manual/círculo métrico, radio0.1–50km y alternativa expandible Indicar coordenadas. Atribución OSM visible fuera del mapa para texto ampliado; fallo permite reintentar mapa y conserva formulario. Guardar mantiene etiqueta/shimmer y éxito confirmado en toast superior; errores contextuales, shake de nombre y consulta de versión actual con confirmación de descarte. Atrás/retorno bloqueados durante escritura; cancelar no persiste.

Cabecera queda fuera de cover/stagger; pasos listado/editor los usan sin reinicios por edición/slider/teclado. Inicio del scroll restaurado al cambiar etapa. Renders con fuentes reales se generan con `flutter test --no-pub --dart-define=CAPTURE_ZONES=true test/interest_zones_test.dart` en `build/ui-preview/zones`; tamaños390×844 y320×350 texto2, incluido modal completo. Las fixtures no son datos de producto ni cartografía remota validada. Véase ADR-018.
