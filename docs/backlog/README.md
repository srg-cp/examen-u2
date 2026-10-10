# Backlog de Entre Huellas

Sincronización: 10 de octubre de 2026, America/Lima. Repositorio: [srg-cp/entrehuellas](https://github.com/srg-cp/entrehuellas/issues).

Hay **51 archivos de issue**, uno por cada #1–#51, además de este índice. El nombre combina número GitHub e identificador HU, por ejemplo `017-HU-01.1.md`. Se conservan descripción, aceptación, dependencias, validación y definición de terminado del issue, junto a metadatos, estado y motivo de clasificación.

Son **12 épicas** y **39 historias ejecutables**. No contar ambas como el mismo esfuerzo. [BACKLOG_MVP](../BACKLOG_MVP.md) conserva la estructura académica y [ESTADO](../ESTADO.md) la evidencia del avance.

## Estados y evidencia

| Estado | Total de issues | Historias ejecutables | Épicas |
| --- | ---: | ---: | ---: |
| Backlog | 36 | 28 | 8 |
| Ready | 2 | 1 | 1 |
| In Progress | 13 | 10 | 3 |
| In Review | 0 | 0 | 0 |
| Done | 0 | 0 | 0 |

- **Backlog**: falta un resultado previo de una dependencia o concretar reglas; no significa listo para comenzar.
- **Ready**: resultado, criterios y contratos necesarios disponibles para iniciar. Aún sin implementación; la estimación se acuerda antes de comprometer la entrega. El acceso local existe aunque su validación integrada esté pendiente; cada nueva entrega debe probar sus permisos reales antes de cerrarse.
- **In Progress**: implementación iniciada o local disponible, con criterios o validación integrada pendientes.
- **In Review**: entrega presentada a revisión mediante PR y evidencia verificable. No se encontraron PRs en esta consulta.
- **Done**: todos los criterios demostrados, código integrado, datos/permisos validados y estado actualizado. No hay evidencia suficiente para clasificar una historia completa aquí.

Las épicas agregan el estado de sus historias: trabajo iniciado → In Progress; sin trabajo iniciado y alguna historia Ready → Ready; sin entregas preparadas → Backlog. Solo pueden terminar después de todas sus historias y demo integrada. No son historias adicionales de implementación.

## GitHub y alcance de la sincronización

Los estados están aplicados a los issues mediante etiquetas `status:backlog`, `status:ready`, `status:in-progress`, `status:in-review` y `status:done`. Se distingue `type:epic` de `type:story`. #44 y #51 llevan `needs:refinement`. Los 51 issues permanecen abiertos y asignados a srg-cp.

**Tablero sincronizado:** [EntreHuellas — Backlog](https://github.com/users/srg-cp/projects/3/views/1). Se verificaron los 51 items del repositorio: 36 Backlog, 2 Ready y 13 In progress, sin items en In review o Done. El 10 de octubre se actualizaron #2 y #26 en etiquetas y Status nativo; ambos siguen abiertos. No se guardaron tokens en el repositorio.

Referencia del mecanismo y permisos de Projects: [documentación oficial de GitHub](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects).

Estos archivos son una instantánea del issue y su estado a esta fecha, no una sincronización automática. GitHub es la referencia operativa; al modificar criterios, etiquetas o Status de Projects, mantener coherentes tarjeta, etiqueta, archivo e índice. Un cambio de estado no demuestra aceptación ni sustituye pruebas. Los enlaces locales facilitan consultar relaciones sin salir del repositorio.

Actualización autorizada el 9 de octubre: Perfil #23 y mascotas #3/#28/#29 en In progress; fotos #4/#30 en Ready. No se marca Done ni se cierra ningún issue sin evidencia integrada. Status y etiquetas verificados después del cambio.

Actualización autorizada el 10 de octubre: Zonas #26 y su épica #2 pasan de Ready a In progress. Implementación local verificada; patch010 aplicado en Supabase según el usuario. Falta demostrar el recorrido real Android/Supabase e integrar el código. Preferencias #27 permanece en Backlog.

## In Progress

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#1](001-HU-01.md) | Épica | Épica — HU-01 — Entrar y gestionar mi cuenta |
| [#2](002-HU-02.md) | Épica | Épica — HU-02 — Elegir zonas y preferencias de alertas |
| [#3](003-HU-03.md) | Épica | Épica — HU-03 — Registrar una mascota |
| [#17](017-HU-01.1.md) | Historia de usuario | HU-01.1 — Registrarme y confirmar mi correo |
| [#18](018-HU-01.2.md) | Historia de usuario | HU-01.2 — Acceder con correo y contraseña |
| [#19](019-HU-01.3.md) | Historia de usuario | HU-01.3 — Acceder con Google |
| [#20](020-HU-01.4.md) | Historia de usuario | HU-01.4 — Conservar y cerrar mi sesión de forma segura |
| [#21](021-HU-01.5.md) | Historia de usuario | HU-01.5 — Completar el onboarding de mi cuenta |
| [#22](022-HU-01.6.md) | Historia de usuario | HU-01.6 — Recuperar mi contraseña con un código |
| [#23](023-HU-01.7.md) | Historia de usuario | HU-01.7 — Consultar y editar mi perfil |
| [#26](026-HU-02.1.md) | Historia de usuario | HU-02.1 — Guardar mis zonas y radios de interés |
| [#28](028-HU-03.1.md) | Historia de usuario | HU-03.1 — Registrar y consultar mis mascotas |
| [#29](029-HU-03.2.md) | Historia de usuario | HU-03.2 — Editar la ficha de mi mascota con sus fotos |

## Ready

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#4](004-HU-04.md) | Épica | Épica — HU-04 — Administrar las fotos de mi mascota |
| [#30](030-HU-04.1.md) | Historia de usuario | HU-04.1 — Agregar fotografías seguras a mi mascota |

## Backlog

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#5](005-HU-05.md) | Historia de usuario | HU-05 — Publicar un caso de mascota perdida |
| [#6](006-HU-06.md) | Historia de usuario | HU-06 — Publicar una mascota encontrada |
| [#7](007-HU-07.md) | Épica | Épica — HU-07 — Consultar y filtrar casos en lista y mapa |
| [#8](008-HU-08.md) | Épica | Épica — HU-08 — Generar y compartir un cartel con QR |
| [#9](009-HU-09.md) | Historia de usuario | HU-09 — Consultar la ficha del caso desde el navegador |
| [#10](010-HU-10.md) | Épica | Épica — HU-10 — Reportar un avistamiento desde web o app |
| [#11](011-HU-11.md) | Épica | Épica — HU-11 — Revisar avistamientos y consultar la cronología |
| [#12](012-HU-12.md) | Épica | Épica — HU-12 — Recibir alertas y consultarlas en la bandeja |
| [#13](013-HU-13.md) | Historia de usuario | HU-13 — Cerrar un caso como recuperado |
| [#14](014-HU-14.md) | Épica | Épica — HU-14 — Denunciar contenido y atender reportes |
| [#15](015-HU-15.md) | Épica | Épica — HU-15 — Conservar borradores sin conexión y reintentar envíos |
| [#16](016-HU-16.md) | Épica | Épica — HU-16 — Consultar estadísticas básicas del MVP |
| [#24](024-HU-01.8.md) | Historia de usuario | HU-01.8 — Solicitar la baja y consultar su estado |
| [#25](025-HU-01.9.md) | Historia de usuario | HU-01.9 — Exportar los datos básicos de mi cuenta |
| [#27](027-HU-02.2.md) | Historia de usuario | HU-02.2 — Configurar mis preferencias de alertas |
| [#31](031-HU-04.2.md) | Historia de usuario | HU-04.2 — Elegir y retirar fotografías de mi mascota |
| [#32](032-HU-07.1.md) | Historia de usuario | HU-07.1 — Consultar y filtrar casos en una lista |
| [#33](033-HU-07.2.md) | Historia de usuario | HU-07.2 — Explorar los mismos casos en el mapa |
| [#34](034-HU-08.1.md) | Historia de usuario | HU-08.1 — Generar un cartel PDF con QR legible |
| [#35](035-HU-08.2.md) | Historia de usuario | HU-08.2 — Descargar y compartir mi cartel y enlace |
| [#36](036-HU-10.1.md) | Historia de usuario | HU-10.1 — Reportar un avistamiento desde la web pública |
| [#37](037-HU-10.2.md) | Historia de usuario | HU-10.2 — Reportar un avistamiento desde Android |
| [#38](038-HU-11.1.md) | Historia de usuario | HU-11.1 — Consultar la cronología del caso |
| [#39](039-HU-11.2.md) | Historia de usuario | HU-11.2 — Revisar y clasificar un avistamiento |
| [#40](040-HU-12.1.md) | Historia de usuario | HU-12.1 — Seguir y dejar de seguir casos y zonas |
| [#41](041-HU-12.2.md) | Historia de usuario | HU-12.2 — Consultar mis alertas en una bandeja persistente |
| [#42](042-HU-12.3.md) | Historia de usuario | HU-12.3 — Recibir notificaciones push con reintento |
| [#43](043-HU-14.1.md) | Historia de usuario | HU-14.1 — Denunciar contenido con un motivo |
| [#44](044-HU-14.2.md) | Historia de usuario | HU-14.2 — Bloquear y desbloquear usuarios |
| [#45](045-HU-14.3.md) | Historia de usuario | HU-14.3 — Revisar denuncias y moderar con auditoría |
| [#46](046-HU-14.4.md) | Historia de usuario | HU-14.4 — Apelar una decisión de moderación |
| [#47](047-HU-15.1.md) | Historia de usuario | HU-15.1 — Conservar borradores al perder conexión |
| [#48](048-HU-15.2.md) | Historia de usuario | HU-15.2 — Reintentar mis envíos pendientes sin duplicarlos |
| [#49](049-HU-15.3.md) | Historia de usuario | HU-15.3 — Consultar casos guardados sin conexión |
| [#50](050-HU-16.1.md) | Historia de usuario | HU-16.1 — Consultar estadísticas agregadas del piloto |
| [#51](051-HU-16.2.md) | Historia de usuario | HU-16.2 — Controlar funciones del piloto con auditoría |

## In Review

Sin issues en este estado.

## Done

Sin issues en este estado.
