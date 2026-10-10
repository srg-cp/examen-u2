# Perfil y fotografía de cuenta

Módulo: `profile`. HU-01.7 / RF-01; [issue #23](../backlog/023-HU-01.7.md).

## Qué hace y cómo se usa

Desde el avatar se accede al perfil. Permite consultar el correo de la sesión,
editar nombre visible y ciudad, elegir una foto propia desde galería y acceder
a zonas de interés y preferencias de alertas. El correo es de solo lectura.
La fotografía de cuenta es independiente de las fotos de cada mascota.

## Reglas, persistencia y errores

Nombre y ciudad son opcionales, de hasta120 puntos de código Unicode cada uno;
se recortan extremos y un vacío se guarda como null. UpdateProfile escribe
solo esos campos y comprueba que la fila confirmada corresponda a la cuenta.
No permite editar propietario, roles ni finalización de onboarding.

La selección de imagen se normaliza a JPEG y se limita a2MiB. El avatar se
guarda en Storage privado y se muestra mediante acceso autorizado; la recuperación
de una selección interrumpida se vincula a la misma cuenta. No se transfieren
pendientes de imagen a otro usuario al cambiar sesión.

Carga inicial mediante skeleton; refresco conserva contenido con progreso fino.
Errores de formulario contextuales; foto de perfil usa toast superior según
ADR-009. El éxito se anuncia tras confirmación. Los cambios se conservan para
reintentar cuando corresponde y se descartan resultados tardíos de otra identidad.

## Dependencias y validación

ReadProfile, UpdateProfile y ChangeProfilePhoto consumen repositorios; las fuentes
encapsulan Supabase y selección nativa. Los enlaces a zonas/preferencias los
compone el router. Depende de SQL de perfil/avatar y reglas privadas de Storage.

Verificar actualización, galería cancelada/interrumpida, sesión A/B y reapertura.
Validación acreditada y pendientes: [ESTADO](../ESTADO.md).
Decisiones: [ADR-008](../decisiones/008-avatar-privado-cuenta.md) y
[ADR-009](../decisiones/009-error-foto-toast-avatar.md).
