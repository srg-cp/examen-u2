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

También se puede ejecutar desde **Run/Debug de `main.dart`** con la extensión Dart/Flutter. El perfil local declara `templateFor` para `lib`, de modo que los lanzamientos predeterminados de archivos de la app utilizan sus argumentos de Supabase sin seleccionar manualmente el perfil. La plantilla cubre `lib` y no se aplica a las pruebas. Detener la ejecución con el botón cuadrado de la barra de depuración y volver a pulsar Run/Debug; hot reload o adjuntarse a una ejecución anterior no incorporan los dart-define. Los botones de extensiones distintas, como Code Runner, no utilizan necesariamente los perfiles de Dart.

La validación distingue configuración vacía, inválida, fallo de inicialización y SDK preparado. `Servicio de acceso preparado` no comprueba conectividad, credenciales remotas ni permisos. Bootstrap inicializa el SDK e inyecta `SupabaseAuthDataSource` y `AuthRepositoryImpl`. El caso de uso `WatchAuthSession` entrega la identidad a `AuthViewModel`, que expone el estado de pantalla. Reiniciar la app reintenta el arranque. Esta separación sigue [las reglas de arquitectura](REGLAS_ARQUITECTURA.md).

En Supabase Dashboard, **Authentication > URL Configuration > Redirect URLs**, registrar exactamente:

```text
entrehuellas://login-callback/
```

Al implementar HU-01, usar `AppConfig.authRedirectUri` como `redirectTo` en OAuth y como `emailRedirectTo` en correo, según el método del SDK. No añadir comodines para esta ruta. La web futura tendrá su propia URL HTTPS; este esquema corresponde al retorno móvil. [Redirecciones oficiales de Supabase](https://supabase.com/docs/guides/auth/redirect-urls).

Android registra esquema `entrehuellas`, host `login-callback` y ruta `/`, permiso INTERNET y actividad `singleTop`. iOS registra el esquema y desactiva también el manejador de enlaces de Flutter; no se compiló iOS en Windows. Supabase Flutter procesa los enlaces mediante app_links y PKCE; go_router conserva las rutas de la UI. [SDK de Supabase Flutter](https://pub.dev/packages/supabase_flutter), [deep links de Flutter y plugins](https://docs.flutter.dev/ui/navigation/deep-linking).

Las tablas de perfil, grants, RLS, funciones y triggers están preparados en `database`, siguiendo [su estructura, generación y ejecución](../database/README.md). No se han aplicado al proyecto remoto. Comprobar permisos con dos usuarios antes de declarar HU-01 completa. El JSON de Flutter contiene configuración pública; no es una conexión SQL para ejecutar esos scripts.

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

El icono Android se genera a partir de los originales de `logo`. Para actualizarlo y comprobarlo instalado, seguir [logo/README.md](../logo/README.md). Una modificación del icono necesita reconstruir/reinstalar; hot reload actualiza el código Flutter, no los recursos del launcher.

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-pub
```

El workflow `.github/workflows/flutter.yml` fija Flutter 3.35.3 y ejecuta resolución con lockfile, formato, análisis y pruebas sin credenciales. Su ejecución en GitHub requiere publicar los cambios; el archivo local no acredita una ejecución remota. Consultar [ESTADO.md](ESTADO.md) para resultados y pendientes reales.

## Probar el login actual

El formulario conecta correo/contraseña y Google con Supabase Auth. En una consulta de solo lectura a la configuración pública de Auth del proyecto local, el 7 de octubre de 2026, Google y correo figuraron habilitados; Apple, deshabilitado y actualmente retirado de la interfaz. Esto no verifica las credenciales OAuth ni el recorrido de retorno.

1. Para ejecución manual en desarrollo, pegar `database/run_all.sql` completo en SQL Editor siguiendo [database/README.md](../database/README.md). Puede repetirse sobre una base compatible; conservar la migración inicial para el historial, sin aplicarla después sobre los mismos objetos ya creados. No requiere colocar claves SQL en Flutter.
2. En **Authentication → URL Configuration → Redirect URLs**, registrar exactamente `entrehuellas://login-callback/`.
3. En **Authentication → Sign In / Providers → Google**, comprobar las credenciales del cliente OAuth web. En Google Cloud, la URI autorizada de retorno es la de Supabase (`https://<project-ref>.supabase.co/auth/v1/callback` en hospedaje gestionado, o `https://<dominio-publico>/auth/v1/callback` con dominio propio); el esquema móvil se configura en Supabase, no como URI HTTPS de Google. [Guía oficial de Google](https://supabase.com/docs/guides/auth/social-login/auth-google).
4. Detener la app y volver a ejecutar ▶ desde `main.dart` con el perfil local y el emulador seleccionado. Abrir acceso.
5. Correo: ingresar una cuenta existente en Authentication → Users, con correo confirmado si el proyecto lo exige. Para una prueba inicial, crearla desde Add user; no insertar contraseñas mediante nuestros scripts SQL.
6. Google: pulsar el botón, elegir cuenta en el navegador y completar el retorno. La app debe mostrar **Sesión activa.**; abrir el navegador por sí solo no confirma éxito.
7. Cerrar sesión, volver a ingresar y reiniciar la app para revisar persistencia. Probar también una contraseña incorrecta: debe aparecer un mensaje seguro y permitir reintentar.

En web, OAuth usa el retorno de Site URL configurado en Supabase; la prueba principal de este incremento es Android. Registro, recuperación y edición de perfil no están implementados aún. [API oficial OAuth Flutter](https://supabase.com/docs/reference/dart/auth-signinwithoauth), [perfiles y triggers de Auth](https://supabase.com/docs/guides/auth/managing-user-data).


## Diagnóstico del callback Google con dominio propio

El 7 de octubre de 2026 se consultó el endpoint público `/auth/v1/authorize?provider=google`, solicitando el retorno móvil y sin seguir la redirección ni autenticar una cuenta. La respuesta HTTP 302 envió a Google:

```text
https://entrehuellas-supabase.kormind.com/auth/v1/auth/v1/callback
```

La captura de Google Cloud autoriza `https://entrehuellas-supabase.kormind.com/auth/v1/callback`. La ruta duplicada explica `redirect_uri_mismatch`: Google exige coincidencia exacta de la URI con el cliente OAuth usado.

En la configuración efectiva del servicio Auth/GoTrue del servidor, el valor debe ser:

```dotenv
GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI=https://entrehuellas-supabase.kormind.com/auth/v1/callback
```

Revisar el Compose o la plantilla del despliegue que construye esa variable. Por ejemplo, si `API_EXTERNAL_URL` ya termina en `/auth/v1`, añadir nuevamente `/auth/v1/callback` duplica la ruta; en esa composición corresponde `${API_EXTERNAL_URL}/callback`. La ubicación y composición exactas dependen del despliegue. Añadir una variable al `.env` no basta si Compose la sobrescribe o no la pasa al contenedor. Recrear/redesplegar el servicio Auth para aplicar el cambio y comprobar de nuevo su redirección. No modificar a ciegas `API_EXTERNAL_URL`, que también puede ser usado por otras partes del servicio.

Mantener el callback correcto en las URIs autorizadas del mismo cliente web de Google y `entrehuellas://login-callback/` en la allowlist de retorno de Auth. Esta corrección pertenece al servidor; `supabase.local.json` conserva la URL base de Supabase y la clave publicable de Flutter. No se ha accedido a la configuración privada ni modificado el despliegue. No añadir la ruta duplicada a Google como solución.

Referencias: [OAuth autohospedado de Supabase](https://supabase.com/docs/guides/self-hosting/self-hosted-oauth), [coincidencia del redirect URI en Google](https://developers.google.com/identity/protocols/oauth2/web-server#authorization-errors-redirect-uri-mismatch).

## Activar onboarding por cuenta

Volver a ejecutar el contenido completo del `database/run_all.sql` actualizado en SQL Editor. Ahora incluye 008–009: `profiles.onboarding_completed_at` y RPC `complete_onboarding()`. No reejecutar la migración inicial estricta sobre los objetos ya creados. En despliegue por CLI, aplicar la nueva migración `20261007000200_onboarding_completion.sql` respetando el historial existente.

Reiniciar la app para incorporar el asset. Sin sesión se abre login. Tras entrar, completar las tres etapas y pulsar Comenzar; cerrar sesión y volver a ingresar con la misma cuenta debe abrir la app directamente. Otra cuenta sin completar onboarding debe ver sus tres etapas. Si el perfil o la columna aún no existen, se presenta un error de preparación con reintento: aplicar SQL antes de probar este recorrido.

Si tras aplicar SQL PostgREST aún no reconoce la columna o RPC nueva, recargar su caché de esquema con `notify pgrst, 'reload schema';` desde SQL Editor y reintentar. No altera el esquema ni reemplaza la migración.

## Probar el registro por correo

Desde el login, abrir Crear cuenta y completar nombre, correo, contraseña de al menos ocho caracteres y confirmación. El cliente llama Supabase Auth con metadata `full_name`; el trigger 002 ya versionado crea el perfil. El SQL existente debe estar aplicado: no hay una tabla nueva de contraseñas ni una migración adicional para este formulario.

En el Supabase administrado con Dokploy, comprobar que el registro por correo esté habilitado, el servicio SMTP funcione y la plantilla Signup utilice el enlace de confirmación de Auth (`ConfirmationURL`). Mantener `entrehuellas://login-callback/` en la allowlist de Redirect URLs. La app envía ese retorno en signup y reenvío; no cambiarlo en el JSON local. Configurar la longitud mínima de contraseña del servidor a ocho o más; la validación cliente no reemplaza esa configuración.

Con confirmación de correo activa, el registro sin sesión muestra Revisa tu correo y permite reenviar el enlace tras 60 segundos. No muestra una cuadrícula OTP: la verificación actual es por enlace. Abrir el correo en el mismo dispositivo, confirmar y comprobar retorno a la app/onboarding. Si ya no se conserva el contexto del enlace, volver a iniciar sesión con correo/contraseña después de confirmar. Con confirmación desactivada y sesión devuelta por Auth, el flujo observado dirige al onboarding sin pantalla de correo.

El resultado sin sesión no se utiliza para afirmar que el correo es nuevo: Auth puede devolver un usuario ofuscado para una cuenta existente según su configuración. Se muestra la misma orientación de confirmación. No se infiere existencia a partir de metadata o identidades.

Comprobar con una cuenta de desarrollo: nombre en el perfil propio, primer onboarding, reingreso sin repetirlo, contraseña distinta en confirmación, límite de reenvíos, retorno con app abierta/cerrada y error de conexión. La implementación se probó con SDK real y HTTP sustituido; no acredita entrega SMTP ni retorno real del correo. [Registro en Supabase](https://supabase.com/docs/reference/dart/auth-signup), [reenvío](https://supabase.com/docs/reference/dart/auth-resend).
