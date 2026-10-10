# Acceso y recuperación de contraseña

Módulo: `auth`. Trazabilidad: HU-01 / RF-01,34; [issue #1 y subtareas](../backlog/001-HU-01.md).

## Qué hace y cómo se usa

El acceso comienza en login. Permite entrar con correo/contraseña o Google,
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
Abrir Google no confirma acceso: se espera una sesión de Supabase Auth.
El SDK gestiona PKCE y el callback móvil configurado; las rutas privadas requieren
sesión y onboarding completo. La recuperación tiene su propio destino protegido.

Los errores se muestran en el contexto del formulario, sin mensajes internos
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
