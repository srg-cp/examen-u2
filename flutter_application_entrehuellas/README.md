# Entre Huellas: aplicación Flutter

Aplicación de recuperación colaborativa de mascotas. Android es la plataforma prioritaria; se conservan las demás plataformas del proyecto existente.

## Arquitectura

Clean Architecture por funcionalidad con MVVM en presentación. Las pantallas consumen ViewModels; las operaciones se expresan como casos de uso; los repositorios y adaptadores concentran el acceso a Supabase. Riverpod gestiona estado e inyección y go_router la navegación.

Esta separación permite probar las reglas y estados sin un servidor y preparar la coordinación futura de datos remotos, borradores y envíos pendientes. La justificación completa está en [ADR-001](../docs/decisiones/001-arquitectura-aplicacion.md). Los límites obligatorios se describen en [REGLAS_ARQUITECTURA.md](../docs/REGLAS_ARQUITECTURA.md) y el árbol de componentes en [ARQUITECTURA.md](../docs/ARQUITECTURA.md).

## Desarrollo

Flutter 3.35.3 / Dart 3.9.2. Desde esta carpeta:

```powershell
flutter pub get --enforce-lockfile
flutter run -d chrome
```

Para conectar Supabase, completar `config/supabase.local.json` con URL y clave publicable siguiendo [CONFIGURACION.md](../docs/CONFIGURACION.md). Ese archivo está ignorado por Git. En VS Code, seleccionar **Entre Huellas - desarrollo local** y ejecutar con F5; el perfil **Entre Huellas - sin Supabase** permite explorar la app sin configuración.

Por terminal, el arranque configurado es:

```powershell
flutter run --dart-define-from-file=config/supabase.local.json
```

## Comprobaciones

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

La base implementa navegación, arranque y observación de sesión. Registro, login completo y perfil pertenecen a HU-01. Consultar [ESTADO.md](../docs/ESTADO.md) para resultados de pruebas y pendientes de Android/Supabase.
