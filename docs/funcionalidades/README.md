# Funcionalidades de Entre Huellas

Documentación del comportamiento implementado al 10 de octubre de 2026.
Cada ficha explica propósito, recorrido, reglas, persistencia, errores y
validación. Se actualiza junto con el código cuando cambia una funcionalidad.
Una funcionalidad implementada no equivale a una historia cerrada: la evidencia
de pruebas y despliegue se registra en [ESTADO](../ESTADO.md).

| Funcionalidad | Módulo Flutter | Trazabilidad |
| --- | --- | --- |
| [Acceso y recuperación](acceso.md) | auth | HU-01; RF-01,34; issue #1 y subtareas |
| [Onboarding por cuenta](onboarding.md) | onboarding | Flujo de entrada de HU-01; ADR-004 |
| [Inicio y navegación](inicio.md) | home | Composición de recorridos, sin entrega de casos o alertas |
| [Perfil y foto de cuenta](perfil.md) | profile | HU-01.7; RF-01; issue #23 |
| [Mascotas](mascotas.md) | pets | HU-03; RF-03; issues #3, #28, #29 |
| [Fotos de mascotas](fotos-mascotas.md) | pets y Edge pet-photo-process | HU-04; RF-03; issues #4, #30, #31 |
| [Zonas de interés](zonas.md) | interest_zones | HU-02.1; RF-02,16; issue #26 |
| [Preferencias de alertas](preferencias-alertas.md) | alert_preferences | HU-02.2; RF-02,16; issue #27 |
| [Casos perdidos](casos-perdidos.md) | lost_cases | HU-05; RF-05; issue #5; implementación local |

Las HU son identificadores del producto; los números # son issues de GitHub.
El detalle de subtareas se conserva en [backlog](../backlog/README.md).

Todas las funcionalidades siguen [las reglas de arquitectura](../REGLAS_ARQUITECTURA.md):
pantallas → ViewModel → casos de uso → contrato de repositorio → fuente de datos.
Las sesiones y permisos se comprueban también en servidor; la UI no sustituye
RLS, grants ni restricciones. Al cambiar de cuenta se descartan resultados
tardíos y datos privados de la identidad anterior.

Casos encontrados, exploración de casos, cartel/QR, avistamientos,
bandeja y entrega real de alertas siguen en los sprints posteriores de
[GUIA_MVP](../GUIA_MVP.md). Las preferencias guardadas no envían avisos.

Para cada incremento, actualizar su ficha, enlazar nuevas fichas aquí y
registrar en ESTADO la validación real y lo pendiente. Los motivos técnicos van
en ADR; los pasos de activación van en CONFIGURACION, evitando copias de SQL o
comandos de despliegue que puedan divergir.
