# Diseño de la interfaz

Dirección visual definida el 7 de octubre de 2026. Las referencias de la interfaz aportan tarjetas amplias, esquinas redondeadas, botones tipo píldora y una jerarquía de texto marcada. Entre Huellas conserva el verde de su marca y utiliza fondos claros con superficies menta y durazno.

## Componentes y estilo

Norma de transiciones y carga: [ADR-006](decisiones/006-transiciones-y-carga-con-shimmer.md). Entradas y cambios discretos usan cover plano → stagger, con marca fuera del efecto. También Contraseña actualizada y resultados de error tienen etapas propias. Login e Inicio incorporan entrada de contenido; onboarding conserva su gesto y reveal textual. Edición/contadores/reenvío no repiten las animaciones.

Arranque: splash nativo Android y presentación Flutter comparten fondo blanco #FFFFFF y el PNG de marca. Android 12+ usa recursos explícitos de splash en modos claro/oscuro; la animación de texto ocurre en Flutter. StartupReveal muestra el icono centrado de 96 px, luego lo desplaza 86 px a la izquierda mientras el nombre en dos líneas emerge detrás hacia la derecha. Deslizamiento horizontal easeOutBack: logo y texto sobrepasan ligeramente su posición y regresan, sin traslación vertical; máscara del texto sigue el borde derecho del icono y deja margen para el rebote. Secuencia única de 1100 ms con breve espera inicial/final; ajusta el conjunto a pantallas pequeñas y omite movimiento cuando se solicita. La ruta de destino se monta al terminar, evitando consumir cover/stagger detrás del splash; acceso usa NoTransitionPage para no sumar un fundido de plataforma. La espera de sesión/cuenta conserva la marca y el fondo. Cambios nativos requieren recompilar/reinstalar, no Hot Restart.

El drawable de splash API 31+ usa InsetDrawable con margen proporcional de 33.3333% por lado. El icono ocupa el tercio central de los límites entregados por Android y queda dentro de la máscara circular. Se reemplazó el lienzo con capas de tamaño fijo porque la captura del usuario confirmó que seguía recortándose. El drawable anterior a Android 12 conserva su tamaño directo; no se modifica el PNG ni el icono del launcher.

Los botones mantienen su etiqueta durante trabajo real y muestran LoadingShimmer (barrido de 1400 ms, recortado al radio del botón); nunca se cambian a Enviando/Guardando con puntos suspensivos ni a un spinner. Cada nueva carga inicia el barrido desde el borde y atenúa el contenido a opacidad 0.72, con brillo encima. Dimensiones y etiqueta se conservan; control deshabilitado y mensaje de progreso para lectores de pantalla. Movimiento reducido deja brillo estático. Deshabilitación/cooldown no activan shimmer. Verificación de OTP y reenvío usan indicadores distintos, según la operación activa.

| Elemento | Convención |
| --- | --- |
| Fondo | Claro, `#F6F7F4`; evita bloques extensos de color saturado. |
| Texto principal / acciones | Verde muy oscuro, `#17231C`, con contraste sobre superficies claras. |
| Texto secundario | `#626E65`; conserva legibilidad y tamaño adaptable. |
| Acento de marca | Verde `#137B50`. |
| Tarjetas destacadas | Menta `#E0F2E5` o durazno `#F5E9E0`. |
| Tarjetas de contenido | Radio 32; padding 18–24 según el componente. |
| Contenedores pequeños | Radio 18 para estados y controles de regreso. |
| Botones principales | Forma píldora, mínimo 58 de alto, texto y flecha; espacio para que el texto crezca. |
| Tipografía | Sans serif del sistema (`sans-serif`), jerarquía por tamaño/peso y espaciado. “Sans serif” es una familia de estilo; no se recibió un archivo de fuente específico. No se distribuye la fuente propietaria de Apple. |
| Ancho de contenido | Máximo 520; se adapta a móvil y pantallas más amplias. |

Los valores implementados se mantienen en `AppTheme`/`AppColors` y los componentes compartidos en `core/presentation/widgets`. Las pantallas componen estos elementos; las reglas de negocio siguen en ViewModels/casos de uso según [REGLAS_ARQUITECTURA.md](REGLAS_ARQUITECTURA.md).

La implementación utiliza Flutter con un tema y componentes propios sobre Material. `bootstrap.dart` prepara la configuración y los repositorios al arrancar; no es el framework Bootstrap de interfaces web.

## Pantallas de la base

**Entrada:** el login es la primera pantalla sin sesión. Se retiró la bienvenida pública anterior y la pantalla intermedia “Tu cuenta”. Tras autenticar se consulta la finalización del onboarding; una cuenta que ya lo completó entra directamente a la app.

**Iniciar sesión:** fondo blanco, contenido centrado en el alto disponible y scroll con teclado/texto ampliado. Marca con icono 80/texto 32, título 48, sin subtítulo, con 14 px de separación respecto al logo; campos de texto 16 y radio 22; ingreso de texto 18/alto mínimo 60/radio 24; Google de texto 15/icono 20/alto mínimo 56. Recuperación usa 16 y pie de cuenta 15. Apple se retira por indicación del usuario. No hay avisos de arranque o mensajes informativos de sesión entre el título y los inputs; los errores de credenciales se señalan en su input con borde rojo y una sacudida breve; los fallos generales usan mensajes breves dentro del contexto, con semántica accesible. El ingreso consume LoginViewModel y la sesión confirmada dirige al onboarding pendiente o a la app. Crear cuenta y Recuperar contraseña están disponibles; validación remota pendiente.

La ilustración y su origen se documentan en [assets/illustrations/README.md](../flutter_application_entrehuellas/assets/illustrations/README.md). El logo visible dentro de la app procede del mismo PNG que el icono clásico de Android. El login reutiliza `BrandMark` desde `core/presentation/widgets`, con el asset en `assets/branding/app_icon.png`; se conserva el original en `logo/` y no se duplica otro PNG para esta pantalla.

## Accesibilidad y validación

**Crear cuenta:** accesible desde el pie del login, fondo blanco y bloque centrado/desplazable con marca de icono 80/texto 32, título 48, con la misma posición y separación de 14 px del login y cuatro inputs de texto 16/radio 22. Nombre, correo, contraseña y confirmación; ambos campos de contraseña tienen visibilidad independiente. Inputs comparten decoración con login, padding vertical 22 y horizontal 16, borde danger de 3.5, icono/texto danger, fondo normal y shake en el campo afectado. Acción de alto mínimo 60/texto 18. Sin casilla legal ni enlaces pendientes por decisión del usuario; no se registra aceptación inexistente.

**Recuperar contraseña:** disponible desde ¿Olvidaste tu contraseña?; AuthPageLayout conserva marca/anclaje/título 48 y X de cierre. Texto explicativo 18, un campo de correo con dimensiones de login/registro, Enviar código con authPrimaryButtonStyle y Volver a iniciar sesión. Expansión desde el rectángulo del enlace en 320 ms/contracción en 260 ms; siete elementos StaggerReveal con parámetros compartidos (1390 ms). Edición y errores no reinician la animación. Confirmación reutiliza EmailCodeConfirmation y la mascota del sobre, mensaje neutro sobre existencia de cuenta y reenvío de código con espera de 60 segundos.

**Nueva contraseña:** misma cabecera/campos/acción, dos inputs con visibilidad independiente, pista de ocho caracteres, validación contextual y nueve elementos StaggerReveal (1570 ms). Error de enlace/observación y éxito tienen mensajes/acciones dentro del contenido. Al completar o cancelar se cierra la sesión de recuperación antes del login; el botón de sistema pasa por el mismo cierre. Movimiento reducido elimina efectos; scroll mantiene acciones accesibles en 320 × 350 con escala de texto 2. Renders: recover_password.png, recover_reveal.png, recover_confirmation.png, reset_password.png, reset_password_success.png y variantes pequeñas. Repositorios sustituidos, sin evidencia de entrega de correo.

Tras un registro que requiera confirmación se muestra Revisa tu correo, email y seis casillas para OTP. Se verifica al escribir/pegar seis dígitos, con acción explícita de reintento y reenvío de código con contador de 60 segundos. La sesión solo se establece con verifyOTP de Auth. Los renders de revisión incluyen register.png y register_confirmation.png; usan repositorios sustituidos, no acreditan correo entregado ni cuenta real creada.

Revisa tu correo incorpora el perrito con sobre blanco y sello de corazón rojo del mockup, generado con image_gen en el mismo estilo 3D del onboarding. Asset transparente `assets/illustrations/dog_with_envelope.png`, mostrado completo en 320 × 320 con contain y excluido del lector de pantalla. El layout conserva scroll y acciones accesibles con texto ampliado; `register_confirmation_small.png` revisa 320 × 350 a escala 2. La separación debajo de la mascota es de 8 px. La indicación «Ingresa el código que llegó a {correo}» usa fuente 16 e interlineado 1.4: frase y duración en gris #747781, solo el correo en negro #111111. Esta etapa no incluye Volver a iniciar sesión; se conserva la X de cierre. Origen y prompt en el README de ilustraciones.

Crear cuenta reutiliza el StaggerReveal de Sader por componente, no por línea: cierre, marca, título, los cuatro campos, pista de contraseña y botón. Una sola línea de tiempo de nueve elementos conserva 850 ms por componente, desfase 90 ms, blur 18, desplazamiento -28 y la misma curva; termina en 1570 ms. La ruta reutiliza OriginPageTransition: una superficie redondeada se expande desde el rectángulo real de Crear cuenta hasta ocupar la pantalla (320 ms) y se contrae al mismo origen al cerrar (260 ms). Usa una curva simétrica easeInOutCubic y mantiene el layout a tamaño final y escala su pintura uniformemente, sin deformar ni remaquetar textos. Se desactiva con movimiento reducido; abrir la ruta sin origen utiliza un fundido. La entrada ocurre una vez al abrir la pantalla, sin repetirse con teclado, edición, visibilidad de contraseña, errores o reenvío. Los errores que aparecen después siguen siendo feedback contextual; no esperan otra cascada. La confirmación de correo conserva su flujo. Movimiento reducido muestra los componentes inmediatamente. register_reveal.png captura una fase intermedia para revisión.

- Permitir scroll y respetar áreas seguras. La acción fija no se coloca encima del contenido sin reservar su espacio.
- Mantener texto ampliable. Cuando crece o falta ancho, las tarjetas secundarias se apilan.
- No depender solo del color para mostrar estado; acompañarlo con texto e icono.
- Ocultar del lector de pantalla las ilustraciones decorativas y conservar etiquetas en controles de acción.
- No mostrar botones sin comportamiento ni datos ficticios como si fueran publicaciones reales.
- Conservar estados de carga, error, sesión y recuperación durante cambios de diseño.

Para producir capturas de revisión con Flutter desde la carpeta de la app:

```powershell
flutter test --no-pub tool/capture_ui_preview.dart
```

Genera `build/ui-preview/access.png` y `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png`, a partir de un viewport lógico 390×844, fuentes reales del SDK y un repositorio de sesión sustituido. Las capturas permiten revisar la composición; no acreditan login remoto ni ejecución de ese diseño en un emulador. Se complementan con pruebas en 320×350 y texto a escala 2, análisis, pruebas de navegación/estado y comprobación en dispositivo.

Para incorporar nuevos assets al emulador, detener y volver a ejecutar desde Run/Debug de `main.dart`. La evidencia de validación y los pendientes se mantienen en [ESTADO.md](ESTADO.md).

## Onboarding después del primer ingreso

### Confirmación de correo con seis casillas

Actualización del 8 de octubre por instrucción del usuario: al enviar el código, AuthStageTransition aplica un cover blanco plano de abajo hacia arriba durante 320 ms, limitado al contenido bajo la marca. No hay expansión desde el botón, escala ni esquinas animadas en estos cambios de etapa. El formulario anterior conserva sus controles/estado detrás de la cortina hasta completarla, excluido de interacción y semántica. Al terminar el cover se inicia el stagger del destino; las dos fases son consecutivas. El logo permanece fuera de ambas y conserva su posición/render. La apertura inicial de Crear cuenta conserva su transición de origen independiente.

Cada cambio formulario → confirmación inicia una línea de tiempo StaggerReveal propia después del cover. Conserva nueve intervalos/1570 ms y parámetros compartidos; en la confirmación se animan mascota 2, título 3, explicación 4, casillas 5, ayuda 6 y reenvío 7. Marca y cierre permanecen fuera del nuevo timeline. Recuperación, confirmación y Nueva contraseña comparten AuthPageLayout: verificar OTP cambia únicamente el contenido, conservando la cabecera. Los callbacks externos usan la misma pantalla con entrada directa al reset; no hay transición de origen de ruta. Temporizador, edición, errores y reenvío no reinician los efectos. Movimiento reducido presenta el destino inmediatamente. Capturas intermedias: register_confirmation_cover/reveal.png, recover_confirmation_cover/reveal.png y reset_password_cover.png.

Texto simplificado por instrucción del usuario: «Ingresa el código que llegó a {correo}.», con el correo real integrado en el párrafo y sin repetirlo en otro bloque. Registro y recuperación comparten esta frase; no se infiere existencia de cuenta a partir de la respuesta. Puede añadirse «Válido por N minutos.» mediante el define público EMAIL_OTP_VALIDITY_MINUTES, únicamente cuando N coincida con la caducidad efectiva de Auth. Mientras no se conozca, se omite la cifra. El define solo describe el plazo; el servidor sigue validando la expiración.

Actualizado el 8 de octubre de 2026: registro y recuperación comparten EmailCodeConfirmation. La mascota, título 32 y tipografía de correo/explicación 18 se conservan. Seis casillas de radio 12, separación 8 y altura mínima 56; su altura crece con el texto. Un solo TextField accesible recibe teclado numérico, autofill oneTimeCode y pegado/retroceso, conserva ceros iniciales y limita a seis dígitos; las casillas visuales no duplican su lectura.

La verificación se dispara al completar los seis dígitos. Si queda un código completo, aparece Verificar código para reintentar; durante una operación se bloquean entradas/acciones. Código incorrecto/vencido usa borde/iconografía contextual danger, ShakeField y mensaje junto a las casillas; no navega a reset ni onboarding. Reenvío usa un TextButton y contador mm:ss (01:00 inicial), conserva el área táctil y limpia las casillas cuando comienza un nuevo periodo de espera. No se muestran instrucciones de abrir enlace. La operación de recuperación mantiene orientación neutral sobre existencia de cuenta.

Los renders de confirmación normal y código con texto a escala 2 están en register_confirmation.png, recover_confirmation.png y register_confirmation_code_small.png. Los repositorios de esas capturas son sustitutos; la entrega/verificación real de correo sigue pendiente.

Tres páginas según el mockup: “Cada huella importa”, “Volvamos a casa” y “Una nueva historia”, con tres ilustraciones independientes derivadas del mockup mediante image_gen, fondo blanco, marca del proyecto, tres indicadores y Continuar/Comenzar. El contenido permite scroll cuando aumenta el texto o baja la altura; los controles inferiores conservan un área segura. Los PNG RGBA de 1254 × 1254 reemplazan el recorte del tablero: se muestran completos con BoxFit.contain. La referencia, método y prompts se documentan en `assets/onboarding/README.md`.

Comenzar guarda la finalización en el perfil remoto de la cuenta. Un fallo de guardado mantiene el onboarding y permite reintentar. Mientras se consulta la sesión/perfil hay un estado de carga; si falla, se ofrece reintento sin saltar el onboarding. La pantalla posterior es una base autenticada para futuras funciones, sin publicaciones ficticias.


### Proporciones del onboarding

El conjunto ilustración/título/descripción se centra horizontal y verticalmente en el espacio entre cabecera y acciones, con scroll si el contenido no cabe. La ilustración ocupa un alto proporcional al viewport limitado por el ancho útil, evitando que un contenedor demasiado alto agregue espacio entre las patas y el título; se muestra sin recortes. títulos de 32, descripciones de 19 y acciones de 18. El encabezado reserva el ancho útil para la marca (icono 56/texto 24), evitando repartirlo con un Spacer que termine reduciéndola. Los indicadores usan círculos de 10 y la acción principal tiene altura mínima 56. Se respeta la escala de texto del sistema.


### Tamaños reforzados y acciones adaptables

Títulos 36, descripciones 22, acción principal 22 con altura mínima 68 y ancho mínimo 180, indicadores circulares de 12. Los PNG mantienen el cálculo de tamaño anterior; se centra el conjunto mediante OnboardingPage. OnboardingActions coloca los tres indicadores centrados encima de la acción, que ocupa todo el ancho disponible y lleva flecha a la derecha. El texto puede envolver al ampliar su escala. Se mantiene la escala del sistema y el contenido desplazable.

El login no lleva subtítulo: “Iniciar sesión” ya explica la acción. La cabecera conserva su escala; el formulario adopta tamaños intermedios para equilibrar legibilidad y espacio.


### Validación de credenciales

El ViewModel publica el campo afectado y un identificador de intento. La UI aplica un outline danger de 3.5 px, iconos y texto ingresado danger y shake horizontal amortiguado de 4 px/360 ms; el fondo conserva su color normal. Correo inválido, contraseña vacía y correo no confirmado usan pistas breves junto al campo. El rechazo genérico marca ambos inputs sin notificación inferior ni párrafo general. Los errores del servicio/OAuth no pintan campos como credenciales incorrectas. Al editar el campo afectado se limpia la señal; al reintentar el mismo error vuelve a animarse. Con animaciones desactivadas permanece el borde/pista sin shake.

El SDK diferencia invalid_credentials y email_not_confirmed; se conservan como fallos de dominio tipados para decidir la señal en presentación. No se interpreta texto externo del SDK ni se adivina cuál credencial fue incorrecta. [Códigos de Supabase Auth](https://supabase.com/docs/guides/auth/debugging/error-codes).

Regla obligatoria: nunca usar SnackBar ni wrappers que lo presenten. Los avisos se mantienen en el contexto correspondiente; no recrear una barra inferior equivalente. [ADR-005](decisiones/005-feedback-sin-snackbar.md).

Los inputs del login usan padding vertical 22 y horizontal 16; los tamaños de campos, marca y título se mantienen.

El botón Google centra icono y texto como un solo grupo, separados por 8 px; no se distribuyen en extremos distintos. El pie de cuenta usa texto 15.

### Entrada suave al onboarding

Durante la consulta de sesión/perfil, la pantalla intermedia muestra la marca estática sobre blanco, sin spinner central ni transición de deslizamiento. El lector de pantalla recibe “Preparando tu cuenta”. Se conserva la consulta real antes de decidir el destino y, si falla, las acciones de reintento y cierre de sesión.

La ruta no aplica un fundido global: evita superponer la marca de espera sobre las mascotas y mantiene la animación limitada al texto. Dentro de cada etapa, solo el título y la descripción usan `StaggerReveal`/`StaggerRevealItem`, de `core/presentation/widgets`. La referencia concreta es el login/raíz de Sader (`apps/sader-panel/src/app/(auth)/page.tsx`), que llama `useStaggerReveal({ count: 5 })` sin modificar los parámetros del hook. Flutter conserva esos parámetros: 850 ms por elemento, desfase 90 ms, desenfoque inicial 18 px, entrada desde 28 px arriba, opacidad y curva `Cubic(0.22, 1, 0.36, 1)`. Cada línea explícita del título y la descripción se revela por separado, mediante StaggerRevealText. Con cuatro líneas el conjunto dura 1120 ms y con cinco, 1210 ms. El lector de pantalla conserva una etiqueta completa para cada bloque. Esta referencia exacta reemplaza el alargamiento anterior por instrucción del usuario. El filtro se desactiva al terminar y con movimiento reducido. Marca, mascotas, indicadores y botones no participan del stagger.

Cada página activa su propio timeline en el último 15 % del desplazamiento de llegada, por deslizamiento o Continuar, sin esperar a ScrollEnd; las páginas vecinas no lo ejecutan anticipadamente. Se conserva el estado de las tres páginas durante el recorrido para no repetirlo al volver atrás. La finalización remota del onboarding conserva su comportamiento. El listener anima únicamente cambios programáticos pendientes: no interrumpe el gesto de un swipe con otro animateToPage.

Con `MediaQuery.disableAnimations` se muestra todo inmediatamente, los botones de etapa cambian de página sin desplazamiento animado. Los controladores se liberan al desmontar; la animación pertenece a presentación y no modifica autenticación ni persistencia del onboarding.

Login y registro comparten AuthPageLayout: una misma área segura, ancho máximo 440 y anclaje superior independiente de la altura del formulario. Conserva la posición de la cabecera del login a escala normal usando su alto de referencia 660; en ventanas bajas reduce el margen superior hasta 28 y permite scroll. La X de cierre del registro se superpone en la esquina superior: no usa AppBar ni desplaza el cuerpo. Título y logo mantienen su geometría al terminar la transición, aunque Crear cuenta tenga más campos.

CreateAccountButton mide su rectángulo respecto al Navigator y lo entrega como dato visual de navegación. La X y el retorno desde confirmación hacen pop para conservar el login anterior y completar la contracción; go hacia login queda como alternativa cuando no hay ruta previa. Durante la transición no se interactúa con el formulario. Capturas register_origin_open.png y register_origin_close.png documentan estados intermedios.

El formulario de registro no muestra subtítulo ni el pie ¿Ya tienes una cuenta?/Iniciar sesión: la X superior cierra la superficie hacia el botón de origen. Login y registro comparten títulos 48 y separación de 14 respecto a la marca.

La X de registro queda a 16 px del borde izquierdo del contenedor compartido. El título usa 44 y separación 14 con el logo en ambos formularios; Google usa icono 20 y texto 15, manteniendo separación 8 y altura del botón 56.

Marca y títulos se alinean al margen izquierdo de 24 px, manteniendo su anclaje y tamaños compartidos. Placeholder y texto ingresado usan 16 con altura de línea de 27 px, conservando la altura exterior de los campos y sus paddings/radios. La expansión al origen dura 320 ms y la contracción 260 ms; el stagger conserva sus parámetros.

Títulos de login/registro: 48, separación superior con la marca 14 y espacio inferior hacia el formulario 20. Inputs: placeholder y texto ingresado 16, manteniendo altura de línea 27 y dimensiones exteriores. Ingresar muestra su etiqueta centrada sin chevron; conserva el estado de carga y el área táctil.

Los cuatro inputs de registro usan las mismas dimensiones y decoración que los de login (padding 22 vertical/16 horizontal). Ingresar y Crear cuenta comparten authPrimaryButtonStyle: padding 18 vertical/24 horizontal, radio 24, alto mínimo 60 y texto 18. La geometría renderizada de ambos formularios se compara en las pruebas de registro.

Continuar con Google: icono 20, altura mínima 56 y padding vertical 13/horizontal 22; conserva texto 15 y separación icono/texto 8.

Las mascotas del onboarding disponen de margen horizontal 12, frente a 24 antes, y alto proporcional 0.68 (límite 180–460), siempre con BoxFit.contain. El texto conserva margen total 24 y sus tamaños. Los indicadores usan diámetro 12 y margen 5; Continuar/Comenzar usa radio 26, ancho completo y alto mínimo 68.
