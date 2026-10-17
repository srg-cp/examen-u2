# Acceso y recuperación de contraseña

Módulo: `auth`. Trazabilidad: HU-01 / RF-01,34; [issue #1 y subtareas](../backlog/001-HU-01.md).

## Qué hace y cómo se usa

El acceso comienza en login. Permite entrar con correo/contraseña, Google o Facebook,
crear cuenta, confirmar el correo con código de seis dígitos y recuperar la
contraseña. Crear cuenta solicita nombre, correo, contraseña y confirmación.
Si Auth exige confirmación, el usuario introduce el código del correo; una
sesión autoconfirmada pasa igualmente por el control de onboarding.

Desde ¿Olvidaste tu contraseña? se solicita un código sin revelar si el correo
existe. Tras verificarlo se abre Nueva contraseña. Cancelar o terminar ese
recorrido cierra la sesión de recuperación; reingresar comprueba la nueva clave.
El reenvío de códigos tiene espera de60s en cliente y límites de servidor.

## Reglas, datos y errores

Se valida correo, longitud mínima de contraseña y coincidencia de confirmación.
No se recortan espacios de contraseñas ni se conservan contraseñas en providers.
Abrir Google o Facebook no confirma acceso: se espera una sesión de Supabase Auth.
El SDK gestiona PKCE y el callback móvil configurado; las rutas privadas requieren
sesión y onboarding completo. La recuperación tiene su propio destino protegido.

Los errores se muestran en el toast superior compartido, sin mensajes internos
del SDK. Durante una solicitud real el botón conserva su etiqueta con shimmer
y bloquea envíos duplicados. La cuenta no se considera autenticada por mostrar
un éxito de registro ni por iniciar el navegador de OAuth.

## Dependencias y validación

Supabase Auth, configuración pública de Flutter, callback Android y SMTP del
Auth autohospedado. Los límites críticos pertenecen al servidor. Los casos de
uso incluyen SignIn/SignOut, RegisterAccount, VerifyRegistrationCode,
RequestPasswordRecovery, VerifyRecoveryCode, ResetPassword y EndPasswordRecovery.

Las pruebas y demos acreditadas constan en [ESTADO](../ESTADO.md); entrega de
correo, caducidad, OAuth y reentrada deben comprobarse en el entorno real.
Exportación/baja de cuenta del alcance general de HU-01 no se dan por entregadas
por estos recorridos. Activación: [CONFIGURACION](../CONFIGURACION.md).

Facebook (17 de octubre de 2026): implementación local sobre el mismo caso de
uso, repositorio y callback móvil. Configuración Meta/App ID/App Secret en Auth,
modo de pruebas/publicación y recorrido de validación en
[LOGIN_FACEBOOK](../LOGIN_FACEBOOK.md). No hay secreto nuevo en Flutter ni
migración SQL. Activación remota y acceso real con Facebook pendientes;
la implementación no cierra HU-01.

Ajuste visual solicitado el17 de octubre: Facebook usa azul #0866FF e icono
de24px para igualar la presencia visual del asset Google de20px (el glifo
Material incorpora margen interior). Ambos botones sociales comparten altura
mínima50px y padding vertical10px; conservan crecimiento con texto ampliado,
área táctil, shimmer y comportamiento de acceso.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Login, registro, OTP y recuperación anuncian validación/fallos en toast; los inputs conservan marcas y shake sin textos debajo. Registro distingue mensaje informativo de fallo incluso durante cooldown.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
