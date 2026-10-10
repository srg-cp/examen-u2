# Inicio y navegación

Módulo: `home`; composición y protección de rutas en `app`.

## Qué hace y cómo se usa

Es el destino tras iniciar sesión y completar onboarding. Compone Inicio,
Explorar y Mis mascotas mediante la navegación compartida. La cabecera incluye
el acceso al perfil y el control de alertas. Mis mascotas recibe el contenido
real de la funcionalidad pets desde la composición de la app.

HomeViewModel mantiene la sección seleccionada; la pantalla observa ese estado.
Bootstrap/router conectan funcionalidades sin que home importe sus repositorios
ni combine directamente providers de infraestructura.

## Alcance actual y estados

Mis mascotas permite el recorrido documentado en [Mascotas](mascotas.md).
Los accesos de casos, exploración y alertas pendientes muestran información
explícita de disponibilidad. No representan una lista/mapa de casos ni una
bandeja operativa, y no publican una pérdida al pulsarlos.

La cabecera permanece fuera del reveal del contenido. Navegación y cargas
reutilizan las reglas visuales compartidas; al cambiar identidad se protege el
contenido privado y el router devuelve a login cuando corresponde.

## Validación

Comprobar acceso autorizado, cambio de sección, entrada a mascotas/perfil,
cierre de sesión y dimensiones pequeñas con texto ampliado. No atribuir
funcionalidad de casos o alertas al shell. Evidencia: [ESTADO](../ESTADO.md).
