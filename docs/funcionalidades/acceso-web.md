# Acceso web

## Toast web alineado con móvil —18/10/2026

Por solicitud del usuario, TopToast compartido reproduce ConfirmationToastHost
móvil: cápsula #F5F5F7 al90%, borde blanco70%, radio28px, blur18px y sombra
#24282A al10% desplazada6px/blur20px. Ancho ajustado al mensaje hasta360px,
márgenes laterales24px y safe-area superior+12px, mínimo48px, padding16/8px.
Icono Material Rounded oficial20px dentro de círculo neutro32px; error_outline
en #B53F48 para error y check #111111 para confirmación. Texto14px/400 (sin negrita, por corrección posterior del usuario),
fuente heredada de la página. Sin X: tocar el aviso o activar su botón mediante
teclado lo cierra. Reintentar sigue siendo acción independiente, cierra primero
y ejecuta su callback. Entrada fade lineal y slide easeOutCubic de180ms;
movimiento reducido estático. Mensajes extensos/texto ampliado pueden hacer
scroll vertical dentro del límite30svh/220px, sin recorte de contenido.

Conserva API show, roles alert/status, expiración web6500ms y limpieza al
desmontar; no se altera autenticación, stagger, orbe ni código Flutter.
La adaptación se comparte con los recorridos que ya consumen TopToast.

Validación: typecheck/build aprobados. QA Chrome del toast confirma cápsula,
blur/iconos/colores, estados alert/status, cierre al tocar y por teclado,
expiración y movimiento reducido;1440/390/320px con texto200% sin overflow,
CSP ni errores de hidratación. Capturas escritorio/móvil revisadas en
apps/mobile/build/ui-preview/web-toast. QA completo de login y moderación
aprobado con backend fixture. git diff --check aprobado. Siguiente paso:
valoración visual del usuario; OAuth remoto conserva su configuración pendiente.

## Port fiel de useStaggerReveal de sader-panel —18/10/2026

Por nueva corrección del usuario, se sustituye la aproximación con keyframes
arrive por el composable compartido app/composables/useStaggerReveal.ts,
portado del hook de sader-panel. Conserva sus opciones active/count/gap/duration,
blur/offset, dirección y orden independientes de entrada/salida, initialDelay,
animateInitial, autoíndice e índice explícito y exitMs. Misma transición de
opacity/filter/transform850ms, curva(.22,1,.36,1), intervalo90ms y doble
requestAnimationFrame al montar/activar, con cancelación al salir/desmontar.
will-change permanece como en la referencia, también al finalizar.

Login consume seis índices explícitos (icono, nombre, título, lema, formulario,
legales), sin keyframes adicionales. La entrada del icono está en un wrapper
exterior al hover, igual que la referencia; no se mezclan ambas transformaciones.
Se preservan fuente Arial, composición, textos, orbe y autenticación.

Adaptación necesaria de Vue/Nuxt: vStaggerReveal aplica los estilos mediante
CSSOM antes del montaje y al actualizar. El HTML SSR usa una clase compartida
con el mismo estado inicial oculto. Así se respeta la CSP existente sin autorizar
estilos inline arbitrarios ni producir flashes por estilos SSR bloqueados.
Movimiento reducido anula opacidad/blur/desplazamiento/transiciones desde el
primer render; editar o comprobar sesión no reinicia el efecto.

Validación: typecheck/build, QA Chrome de recarga/stagger, login completo y
login/legal aprobados. Transiciones reales y posición final estable verificadas;
hover, edición, movimiento reducido y390/320px con texto200% sin regresiones.
Sin errores CSP/hidratación. Capturas revisadas en login-reload; OAuth se valida
con fixture, no constituye confirmación remota. Siguiente paso: revisión visual
del usuario; activación OAuth real pendiente de configuración.


## Retorno glass e identidad legal —18/10/2026

GlassNavigationButton compartido ahora usa chevrón SVG oficial Material
Rounded28px y acabado glass del móvil. Regresión de moderación comprobada.
Por nueva instrucción, solo /terms y /privacy usan DM Sans local; login conserva
Arial. Ver ficha documentos-legales y ESTADO. No cambia la autenticación.

## Recarga de login sin destello crema —18/10/2026

El usuario detecta un destello amarillo al recargar. Causa comprobada:
.login-form usaba .reveal y su pseudo-elemento de cobertura #FFFBEF del
componente global. Se retira esa clase solo del login; no se modifica el
reveal global ni las páginas legales/QR/landing.

Por solicitud expresa, /login adopta la entrada de useStaggerReveal de
sader-panel: opacidad0→1, blur18→0px, translateY(-28px)→0,850ms y curva
cubic-bezier(.22,1,.36,1). Seis grupos con separación90ms: icono, nombre,
título, lema, formulario y enlaces legales. La primera versión reutilizaba keyframes arrive existentes (sustituida por el port descrito arriba),
sin capa pintada; sustituye entrada previa del icono700ms/12px/escala. Hover del
icono1.05 y orbe se conservan. Cabecera entra una sola vez por esta instrucción,
y permanece estable durante sesión/edición; no se remonta ni se repite entrada.
Movimiento reducido muestra todos los grupos estáticos desde el inicio.

Validación: typecheck/build y QA Chrome de carga/recarga aprobados. Comprobados
valores de seis grupos, ausencia de pseudo-elemento en inicio/mitad/final,
capturas de recarga y ausencia de reinicio al editar.390/320px con texto200%,
sin overflow/errores CSP/hidratación. QA login/legal previo aprobado: orbe/hover,
links/retorno/SSR sin JS y1440/390/320. Capturas en
apps/mobile/build/ui-preview/login-reload revisadas. git diff --check aprobado.
Sin cambios de autenticación, SQL, Flutter o despliegue. Siguiente paso:
valoración visual del usuario; OAuth real conserva su configuración pendiente.

## Icono, orbe y enlaces legales —18/10/2026

Por solicitud del usuario se adapta la entrada del icono y hover1.05 de
sader-panel: animación de aparición700ms, hover/foco300ms y movimiento reducido
estático. Editar campos o comprobar sesión no repite la entrada. El orbe ya
existente en login pasa a strong0.62, con colores celestes y sin radial fijo que
oculte su movimiento. AmbientPageShell reutiliza fondo y BackgroundGlowOrb en
login y documentos legales; landing conserva sus estilos e intensidad.

/login añade enlaces reales a /terms y /privacy. Documentos públicos SSR,
composición compartida LegalPage sin dominio/ViewModel vacíos, índice con anclas,
retorno glass al login, enlaces cruzados y mailto al contacto. El usuario confirma
sergiotlv51@gmail.com y korMind cuando sea necesario identificar al responsable.
Contenido redactado como documentos del servicio, sin referencias a MVP/borrador,
sin inventar domicilio, razón social completa o plazos de conservación. Se usa
korMind en identificación y privacidad; el resto mantiene Entre Huellas.

No se crea registro de aceptación/consentimiento ni se modifican cookies, roles
o datos de autenticación. Sin cambios SQL/Flutter, envío de correos o despliegue.
Validación: typecheck,30 pruebas y build Nuxt aprobados. Chrome de producción
con fixtures: entrada/hover del icono, orbe animado, ausencia de reinicio al editar,
movimiento reducido estático; enlaces, retorno glass, anclas y mailto correctos;
SSR sin JavaScript en documentos. Renders1440/390/320 con texto200%, sin overflow
ni errores CSP/hidratación. Se corrigió ajuste de títulos largos para permitir
lectura con texto ampliado. Capturas revisadas en
apps/mobile/build/ui-preview/login-legal. QA completo de login previo también
aprobado, incluidos Google/Facebook fixture. git diff --check aprobado.
Siguiente paso: valoración visual del usuario; OAuth real sigue pendiente de
configuración. No se publica ni despliega.
[Documentos legales](documentos-legales.md) detalla contenido, recorrido y validación.

## Acceso social y formulario estable — 18/10/2026

Se retira el skeleton que sustituía el formulario al comprobar sesión. /login
renderiza el formulario estático desde SSR, mantiene el mismo árbol durante la
consulta y deshabilita envíos con aria-busy hasta terminar, sin shimmer por simple
deshabilitación. La entrada no se repite por comprobación o edición. Se elimina
el texto «Acceso para cuentas autorizadas…». Skeleton de datos de moderación
permanece; este formulario no muestra datos remotos.

Se añaden Continúa con Google/Facebook y separador «o continúa con» siguiendo
móvil, con SocialSignInButton compartido por ambos proveedores e iconos locales.
StartSocialSignIn/CompleteSocialSignIn expresan operaciones de dominio,
HttpSocialSignInRepository y fuente Supabase encapsulan HTTP; AccessViewModel
coordina busy/proveedor, toast y descarte tardío. Plugin compone dependencias.

OAuth servidor PKCE: POST same-origin /api/moderation/oauth/start, redirect a
Supabase y retorno GET /api/moderation/oauth/callback?flow=…&code=…. Cookie de
flujo AES-GCM/HttpOnly/SameSite Lax, scope /api/moderation/oauth,600s, state aleatorio
y verifier privado; código se intercambia solo en servidor. Callback limpia cookie
de flujo y valida estado/expiración antes de intercambiar. Auth/rol se verifican
antes de guardar la cookie de moderación, que conserva SameSite Strict y scope
/api/moderation. No tokens/verifier en payload cliente ni localStorage, ni roles automáticos.
Solo GET callback admite navegación cross-site; las otras API mantienen bloqueo,
protección de origen y límites. Retorno fijo, sin open redirect. Supabase consume
el código una sola vez; pruebas de replay incluidas.

Validación local: typecheck,30 pruebas unitarias/arquitectura, build y8 pruebas
de servidor aprobados. Chrome fixture: ambos proveedores recorren inicio/retorno
y cierre, más flujos previos; formulario SSR sin skeleton/texto retirado. Renders
1920/1440/731/390/320 y texto200% sin overflow/CSP/hidratación; capturas escritorio
y pequeña revisadas en apps/mobile/build/ui-preview/web-login.

Pendiente configuración local (clave publicable, secreto y PUBLIC_WEB_ORIGIN),
habilitación Google/Facebook y allowlist de callback web en Supabase, y demo con
cuentas reales. Proveedores móviles no implican URL web autorizada. Sin cambios
remotos, SQL, Flutter, despliegue o cierre de historia. Siguiente paso: configurar
y verificar la autenticación real; no reaplicar030.

Cancelación del proveedor vuelve a /login?reason=oauth-cancelled con toast;
error/estado incorrecto/código inválido vuelve con oauth-failed; rol ausente
vuelve con forbidden. Reiniciar desde un botón tras fallo. Solo el flujo más
reciente del navegador conserva cookie válida; un flujo anterior falla cerrado.
La autenticación OAuth puede crear/vincular una identidad en Supabase según
su configuración, pero no asigna permisos de revisor ni crea un panel por rol.

Referencia técnica: [PKCE Supabase](https://supabase.com/docs/guides/auth/sessions/pkce-flow)
y [exchangeCodeForSession](https://supabase.com/docs/reference/javascript/auth-exchangecodeforsession).

## Login inspirado en acceso móvil y sader-panel — 18/10/2026

Por petición del usuario, /login toma la composición del acceso móvil y la
columna concentrada de sader-panel, manteniendo Arial/Helvetica/sans-serif.
Marca oficial grande con nombre en dos líneas, título y lema; formulario directo
sin tarjeta exterior ni cabecera/footer institucional duplicados. WebShell
incorpora variante minimal y conserva el enlace de salto accesible.

LoginInput se reutiliza en correo/contraseña: superficie #F5F5F7, radio22px,
iconos de correo/candado, etiquetas flotantes persistentes y control accesible
Mostrar/Ocultar contraseña. Botón Entrar carbón #111111 y texto blanco como
en móvil, cápsula64px; es variante de login autorizada por esta solicitud.
Fondo blanco/celeste/cream y BackgroundGlowOrb soft conservados. Cabecera fuera
del reveal; edición y visibilidad no reinician entrada; movimiento reducido
respetado. No se copian acciones sociales/registro/recuperación que no tengan
implementación web en este alcance. Autenticación, roles y redirecciones iguales.

Validación: typecheck,27 pruebas y build aprobados. QA Chrome de login con
fixtures aprobado (autenticación/roles/redirects/logout/caducidad/reintento),
además de Arial, ausencia de tarjeta y mostrar/ocultar sin perder el valor.
Renders1920/1440/731/390/320, texto200% en320, sin overflow ni errores
CSP/hidratación. Capturas escritorio/móvil/pequeña revisadas en
apps/mobile/build/ui-preview/web-login. Configuración remota/cuenta revisora
y otros navegadores pendientes; sin despliegue ni cambios SQL/Flutter.
Siguiente paso: valoración visual del usuario y acceso real tras configurar servidor.

## Corrección de consulta anónima de sesión — 18/10/2026

La captura del usuario muestra aviso al abrir /login. Diagnóstico local: GET
/api/moderation/session sin cookie devolvía503 porque se validaba configuración
antes de reconocer ausencia de sesión. .env.local tiene SUPABASE_URL pero faltan
SUPABASE_PUBLISHABLE_KEY, MODERATION_SESSION_SECRET y PUBLIC_WEB_ORIGIN.
Solo se inspeccionó presencia de variables, sin mostrar ni modificar secretos.

readModerationSession devuelve401 si no hay cookie antes de componer backend.
Con cookie presente conserva descifrado/Auth/rol y errores reales; login sigue
fallando cerrado si la configuración está incompleta. No se ocultan fallos503
ni se otorgan permisos. Configuración de acceso real sigue pendiente.

Validación: typecheck/build y7 pruebas de servidor de producción aprobados,
incluida regresión sin configuración (sesión anónima401, cookie suministrada503,
login503). Nuxt dev5173 comprobado: sesión sin cookie401, formulario visible sin
toast de conexión y /moderacion redirige a /login. git diff --check aprobado.
Sin cambios de variables, SQL o despliegue. Siguiente paso: configurar servidor
local y comprobar acceso con cuenta revisora real.

HU-14.3 / RF-22,33; issue #45 como recorrido de acceso a moderación existente.
Implementación de login separado por instrucción explícita del18/10/2026.
No equivale a una autenticación web general para todos los roles futuros.

## Qué hace y recorrido

Por autorización del usuario se crea /login como página separada; /moderacion
ya no contiene formulario. LoginScreen/AccessViewModel consumen AccessModeration
y el repositorio HTTP existentes, sin consultar la cola desde el login.
Instancias por consumidor, sin estado privado singleton. Usa WebShell,
BackgroundGlowOrb soft, ActionButton, TopToast y ContentSkeleton, con referencia
visual web vigente, campos accesibles, shake/invalid y shimmer de trabajo real.

Sin sesión, /moderacion redirige a /login; al entrar o visitar /login con sesión
autorizada se vuelve a /moderacion. Destino fijo, sin aceptar URLs de retorno
arbitrarias. Rol denegado se anuncia por toast sin acceder al panel. Expiración,
logout y cambios entre pestañas limpian datos y llevan al acceso cuando procede.
Fallo de red/servidor permite reintento, sin tratarlo como ausencia de sesión.

La cookie conserva alcance /api/moderation, HttpOnly/cifrado/SameSite y permiso
por operación en servidor. La primera visita SSR sirve shell/skeleton público,
y la redirección se ejecuta tras montar en navegador; el middleware protege
navegaciones cliente posteriores. No se afirma redirección HTTP3xx en SSR.
Sin registro, roles nuevos, panel de usuario, cambios SQL/Flutter o despliegue.

## Campos, reglas y feedback

Correo obligatorio con formato y máximo254 caracteres; contraseña obligatoria
hasta1024, autocomplete username/current-password y envío mediante Enter.
Dominio valida antes de enviar. Contraseña se limpia tras el intento o cambio de
pestaña/sesión y al desmontar; no se persiste en navegador. Doble envío bloqueado.
Validación, credenciales inválidas, acceso denegado y fallos van al toast superior;
sin mensajes bajo inputs. Borde/aria-invalid y shake para datos inválidos.
Formulario estático disponible durante la comprobación inicial; controles
bloqueados hasta terminar. Botón Entrar conserva etiqueta y shimmer al enviar.
Cabecera fuera del reveal, sin reinicio de animación al editar. Movimiento reducido
estático; decoración no intercepta eventos ni foco.

## Persistencia y permisos

Sin migraciones ni tablas nuevas. Usa cuentas existentes y endpoints
/api/moderation/session, login y logout. Auth y RPC autorizan cada operación;
login con cuenta sin rol no establece acceso a la cola. El guard organiza
navegación; no sustituye esos controles. La sesión móvil sigue independiente.

## Errores, reintentos y ciclo de vida

401 requiere acceso;403 muestra denegación.503/red conserva posibilidad de
reintentar; en moderación se muestra Reintentar conexión y permanece la ruta.
BroadcastChannel coordina cambios entre pestañas; sesión expirada o perdida borra
contenido privado antes de salir. La disposición invalida respuestas tardías.
Parámetros reason solo seleccionan mensajes locales conocidos; no se reflejan
mensajes arbitrarios ni se acepta un redirect externo.

## Dependencias y activación

Configuración Nuxt/Supabase y cuenta revisora según CONFIGURACION y ficha de
moderación.030 ya confirmado aplicado por usuario; no reaplicar. No crea registro,
recuperación de contraseña ni asignación de roles ficticios. Sin despliegue.

## Validación y pendientes

Validación local: typecheck,27 pruebas unitarias/arquitectura, build Nuxt y
6 pruebas de servidor de producción aprobados. Chrome con backend fixture:
login, validación, denegación de rol, Enter, destino fijo, sesión existente,
logout entre pestañas, recuperación503 y caducidad. QA moderación aprobado
(cola/evidencia/decisiones/reintentos/revocación); sin errores CSP/hidratación.
Renders1920/1440/731/390/320 y texto200% en320, sin overflow; escritorio y
tamaño pequeño revisados en apps/mobile/build/ui-preview/web-login.
Pendiente acceso con cuentas/configuración remotas reales y otros navegadores.
030 confirmado previamente por usuario; no reaplicarlo. Sin publicación/GitHub.

Comprobaciones reproducibles: npm run typecheck, npm test, npm run build,
npm run test:server y scripts/check-login-browser.mjs / check-moderation-browser.mjs
con PLAYWRIGHT_MODULE y CHROME_PATH. Los fixtures no acreditan login remoto real.
