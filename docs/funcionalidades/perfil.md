# Perfil y fotografía de cuenta

Ciudad (16 octubre): reutiliza places, el mismo autocompletado de Ubicación en modo ciudad. Debounce600ms/mínimo3, selección obligatoria para texto nuevo; vacío opcional y valor antiguo sin cambiar conservados. UpdateProfile recibe citySelected explícito; edición/guardado/foto/fallo conservan esa condición y Descartar restituye valor/limpia sugerencias. Guarda nombre/región/país≤120, sin coordenadas nuevas ni cambios SQL del perfil. Router compone el widget por slot, sin import de otra presentación. No es validación de catálogo oficial en servidor. Formato/análisis sin incidencias; sin pruebas ejecutadas por instrucción del usuario, cobertura/Android pendientes. [ADR-051](../decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Ajuste del15 de octubre: acceso visible Ubicaciones de interés en lugar de Zonas de interés; rutas y permisos conservados. Formato/análisis, sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

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


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Consulta, edición, errores de campos y cierre de sesión usan toast. La preparación del avatar delega en el normalizador compartido, manteniendo el recorte512 y la recuperación nativa por cuenta.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
