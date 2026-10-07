# Configuración y validación de la app

Base del chat 00, 6 de octubre de 2026. Flutter 3.35.3 / Dart 3.9.2. Ejecutar los comandos desde `flutter_application_entrehuellas`. Se mantienen el nombre del paquete y las plataformas existentes. Android conserva el identificador provisional `com.example.flutter_application_entrehuellas`; revisarlo antes de distribuir.

## Arranque

```powershell
Set-Location flutter_application_entrehuellas
flutter pub get --enforce-lockfile
flutter run -d chrome
```

Sin configuración se puede navegar entre inicio y acceso. El acceso muestra que falta configurar el servicio. Registro, correo/Google, perfil, baja y exportación pertenecen a HU-01 / RF-01,34; no están implementados por esta base.

## Supabase

1. Crear o identificar un proyecto de desarrollo en Supabase. Obtener su URL HTTPS y la clave **publicable** `sb_publishable_...`.
2. Copiar el ejemplo y completar ambos valores en el archivo local:

```powershell
Copy-Item config/supabase.local.example.json config/supabase.local.json
flutter run --dart-define-from-file=config/supabase.local.json
```

`*.local.json` está ignorado por Git. El ejemplo contiene valores vacíos y puede ejecutarse para comprobar el arranque sin configuración. Los `dart-define` se incluyen en el cliente; usar solo configuración pública. El validador rechaza claves secretas y JWT heredados, incluyendo `service_role`. Esta base requiere la clave publicable moderna. Nunca introducir credenciales SQL o claves de servidor.

### Configuración por entorno y ejecución

El archivo se crea y completa una sola vez por entorno/equipo. Flutter necesita saber qué archivo usar al ejecutar o compilar: `--dart-define-from-file` incorpora esos valores a esa ejecución/build. No se lee un archivo del ordenador del desarrollador desde el teléfono del usuario; una vez instalada la app, el usuario no ejecuta comandos. Si cambias esos valores, detén y vuelve a iniciar la app o genera otro build; hot reload no los actualiza.

Para evitar escribir el comando durante el desarrollo, se añadieron perfiles de VS Code, tanto abriendo la raíz del repositorio como abriendo solo la carpeta Flutter. Con las extensiones Dart/Flutter instaladas, abre **Ejecutar y depurar**, selecciona **Entre Huellas - desarrollo local**, elige un dispositivo y pulsa **F5**. El perfil pasa el archivo local automáticamente. Si aún no existe ese archivo, usa **Entre Huellas - sin Supabase**. Los perfiles contienen rutas y argumentos, sin credenciales. Se validó su JSON y sus rutas; el lanzamiento interactivo F5 queda pendiente. [Configuraciones de ejecución de Dart Code](https://dartcode.org/docs/launch-configuration/).

La validación distingue configuración vacía, inválida, fallo de inicialización y SDK preparado. `Servicio de acceso preparado` no comprueba conectividad, credenciales remotas ni permisos. Bootstrap inicializa el SDK e inyecta `SupabaseAuthDataSource` y `AuthRepositoryImpl`. El caso de uso `WatchAuthSession` entrega la identidad a `AuthViewModel`, que expone el estado de pantalla. Reiniciar la app reintenta el arranque. Esta separación sigue [las reglas de arquitectura](REGLAS_ARQUITECTURA.md).

En Supabase Dashboard, **Authentication > URL Configuration > Redirect URLs**, registrar exactamente:

```text
entrehuellas://login-callback/
```

Al implementar HU-01, usar `AppConfig.authRedirectUri` como `redirectTo` en OAuth y como `emailRedirectTo` en correo, según el método del SDK. No añadir comodines para esta ruta. La web futura tendrá su propia URL HTTPS; este esquema corresponde al retorno móvil. [Redirecciones oficiales de Supabase](https://supabase.com/docs/guides/auth/redirect-urls).

Android registra esquema `entrehuellas`, host `login-callback` y ruta `/`, permiso INTERNET y actividad `singleTop`. iOS registra el esquema y desactiva también el manejador de enlaces de Flutter; no se compiló iOS en Windows. Supabase Flutter procesa los enlaces mediante app_links y PKCE; go_router conserva las rutas de la UI. [SDK de Supabase Flutter](https://pub.dev/packages/supabase_flutter), [deep links de Flutter y plugins](https://docs.flutter.dev/ui/navigation/deep-linking).

No se han creado tablas, grants, RLS ni funciones. Versionarlos en S1 y comprobar permisos con dos usuarios antes de declarar HU-01 completa.

## Prueba Android pendiente

Completar Android SDK Command-line Tools desde Android Studio y revisar los términos con `flutter doctor --android-licenses`. Con un dispositivo Android conectado:

```powershell
flutter doctor
flutter devices
flutter run --dart-define-from-file=config/supabase.local.json
```

En otra terminal, con adb disponible, comprobar apertura con la app cerrada y abierta:

```powershell
adb shell am start -W -a android.intent.action.VIEW -d 'entrehuellas://login-callback/' com.example.flutter_application_entrehuellas
```

Ese enlace sin código comprueba apertura, no autenticación. En S1 iniciar un flujo real de correo/OAuth en el mismo dispositivo, completar el retorno y comprobar sesión restaurada, rechazo de callback inválido y cierre de sesión. PKCE necesita el verificador almacenado al iniciar el flujo; no simular éxito pegando un código arbitrario. No registrar ni compartir la URL de retorno que contiene códigos/tokens.

## Comprobaciones

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-pub
```

El workflow `.github/workflows/flutter.yml` fija Flutter 3.35.3 y ejecuta resolución con lockfile, formato, análisis y pruebas sin credenciales. Su ejecución en GitHub requiere publicar los cambios; el archivo local no acredita una ejecución remota. Consultar [ESTADO.md](ESTADO.md) para resultados y pendientes reales.
