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

## Probar registro y recuperación por código (actualizado el 8 de octubre)

Registro y recuperación usan ahora códigos OTP de seis dígitos escritos dentro de la app. El usuario puede leer el correo en una PC y escribirlo en el teléfono. El código se valida directamente contra Auth con correo y token; no requiere el verificador PKCE de la instalación que lo solicitó. Google y los callbacks existentes conservan su configuración de Redirect URLs.

Revisar que Confirm signup y Reset password incluyan `{{ .Token }}`. El usuario informa que el correo actual ya muestra un código alternativo de seis dígitos; ese código se puede usar en la nueva pantalla. Para presentar solo código y evitar instrucciones de enlace, se prepararon las fuentes [confirm_signup.html](../supabase/auth/templates/confirm_signup.html) y [recovery.html](../supabase/auth/templates/recovery.html), junto a su [procedimiento de aplicación](../supabase/auth/templates/README.md). No se desplegaron ni se modificó Auth remoto en esta tarea.

En el Auth autohospedado con Dokploy, comprobar la configuración efectiva `GOTRUE_MAILER_OTP_LENGTH=6`, caducidad, límites de envío/verificación, SMTP y política de contraseña de al menos ocho caracteres. La espera del cliente es 60 segundos; no sustituye límites del servidor. Las URLs de las plantillas deben estar disponibles desde el contenedor y sus variables transmitidas por Compose antes de redesplegar. No usar una ruta de Windows como URL de plantilla ni guardar secretos en estos HTML.

### Texto de caducidad

Consulta de solo lectura del 8 de octubre: `/auth/v1/health` devuelve Auth `v2.189.0`; `/auth/v1/settings` no expone caducidad del correo. Esa versión [usa 86400 segundos (24 horas) como valor por defecto](https://github.com/supabase/auth/blob/v2.189.0/internal/conf/configuration.go#L1096); no demuestra el valor efectivo del despliegue. Revisar `GOTRUE_MAILER_OTP_EXP` en el servicio Auth de Dokploy y su entorno efectivo: el Compose puede sustituir el valor por defecto.

Cuando se confirme el plazo real, añadir `EMAIL_OTP_VALIDITY_MINUTES` con un entero positivo a la configuración pública de compilación (`config/supabase.local.json` o `--dart-define`) para mostrar «Válido por N minutos.» en ambas confirmaciones. N debe ser `GOTRUE_MAILER_OTP_EXP / 60` si el plazo es un número entero de minutos. Sin valor confirmado, la app muestra solo «Ingresa el código que llegó a {correo}.» y evita afirmar una duración inventada. Este define no cambia la caducidad del servidor ni el contador independiente de 60 segundos para reenviar.

### Registro

1. Desde login, Crear cuenta con nombre, correo, contraseña y confirmación. Con confirmación activa, Revisa tu correo muestra mascota, seis casillas y espera para reenviar. Sin confirmación y con sesión devuelta, entrar al onboarding como antes.
2. Leer el correo en la PC y escribir/pegar el código en el celular. Se verifica automáticamente al completar seis dígitos; si falla hay reintento explícito. `verifyOTP(type: email)` debe devolver sesión antes del onboarding. Probar un código que comience con cero y pegado completo.
3. Probar código incorrecto, vencido/usado y reenvío tras 60 segundos. Un error mantiene el correo y permite corregir/reintentar. Reenvío limpia las casillas. Comprobar perfil/nombre y primer onboarding; el trigger de perfiles ya versionado se mantiene, sin tablas nuevas.

### Recuperación

1. Desde ¿Olvidaste tu contraseña?, introducir correo y Enviar código. La orientación es neutral para cuenta existente/desconocida; reenvío usa la misma solicitud de recuperación y espera 60 segundos.
2. Leer el código en otro equipo y escribirlo en la app. `verifyOTP(type: recovery)` debe establecer sesión de recuperación y abrir Nueva contraseña antes de onboarding/Inicio. No se debe usar signInWithOtp ni un OTP de registro para recuperar contraseña.
3. Probar contraseña corta, confirmación distinta, contraseña anterior y política del servidor; guardar y revisar éxito. Regresar al login cierra la sesión local de recuperación. Comprobar que la nueva contraseña permite entrar y la anterior falla.
4. Probar código inválido/vencido/usado, desconexión al verificar/guardar y cancelación mediante X/retorno de sistema. Un código incorrecto se muestra en las casillas; no abandona el formulario ni habilita reset. Un fallo de cierre permite reintentar.

Si se interrumpe/reinicia la app después de verificar el código y antes de cambiar contraseña, solicitar un código nuevo: el propósito adicional de recuperación no se persiste por instalación. Los OTP no se guardan ni se registran en logs locales.

Las pruebas usan SDK real con HTTP y almacenamiento sustituidos, incluidos dos clientes independientes sin compartir almacenamiento PKCE. Cubren la verificación por código, propósito correcto, respuesta sin sesión, vencimiento y recorrido UI/router. No contactan el servidor, envían correo ni cambian contraseñas reales. Sigue pendiente demostrar lectura en PC → entrada en teléfono con el Auth de desarrollo.

Referencias: [verifyOTP](https://supabase.com/docs/reference/dart/auth-verifyotp), [Token en plantillas](https://supabase.com/docs/guides/auth/auth-email-templates), [configuración autohospedada](https://github.com/supabase/supabase/blob/master/docker/CONFIG.md), [updateUser](https://supabase.com/docs/reference/dart/auth-updateuser).

## Perfil: validación con cuentas reales de desarrollo

El formulario Perfil consulta y modifica solamente nombre visible y ciudad. Campos opcionales, hasta 120 caracteres Unicode; blanco/vacío se guarda como null. El esquema 001–009 debe estar aplicado. No se necesita una nueva migración para este incremento. Si falla la consulta, usar Reintentar; si falla el guardado, los campos se conservan y puede repetirse Guardar cambios.

Para verificar permisos/persistencia con dos cuentas dedicadas de desarrollo:

1. Copiar `config/profile_test.local.example.json` a `config/profile_test.local.json` dentro de la app. El destino queda ignorado por Git. Completar URL/clave publicable y los cuatro valores de las dos cuentas confirmadas de prueba; no compartir contraseñas por chat ni versionarlas.
2. Ejecutar desde `flutter_application_entrehuellas`:

```powershell
flutter test --no-pub tool/check_profile_remote_test.dart --dart-define-from-file=config/profile_test.local.json
```

La prueba ingresa con A y B, modifica datos editables de A y repite el guardado, vuelve a ingresar con un cliente nuevo, comprueba lectura/edición cruzadas rechazadas y columnas de servidor protegidas. Restaura nombre/ciudad originales de A en finally; la fecha updated_at cambia legítimamente. Sin los valores, la prueba queda omitida explícitamente y no contacta el servidor.

Para Android, comprobar además desde la app: entrar → Perfil → editar → guardar → cerrar/reabrir app → consultar; provocar fallo de red al guardar y reintentar; verificar salida y restauración de sesión. La prueba con nuevo cliente no acredita almacenamiento de sesión, SMTP/OAuth ni comportamiento Android. No ejecutar contra cuentas de producción.

Comprobación SQL adicional en desarrollo: `database/tests/003_profile_edit_permissions.sql`; crea fixtures temporales dentro de una transacción y termina con ROLLBACK. `npm test` en database/tests ejecuta los permisos/invariantes en PostgreSQL en memoria, distinto del entorno Supabase remoto.

## Activar foto de perfil privada

El correo del Perfil es de solo lectura y viene de la sesión de Auth. La foto se elige desde el avatar/cámara o Añadir/Cambiar foto; se normaliza a JPEG y usa Storage privado.

Con perfiles/onboarding ya aplicados, ejecutar en SQL Editor de **Supabase de desarrollo** el patch generado `database/patchs/004_patch_profile_avatars.sql`, completo y sin selección parcial, con rol postgres. Crea bucket privado profile-avatars y permisos por propietario. Sustituye la migración 003 que falló con «must be owner of table objects»: usa RLS administrado ya activo sin ALTER TABLE storage.objects. La migración 004 conserva esta corrección en el historial; 003 se conserva pero no se vuelve a ejecutar manualmente. No se ha aplicado remotamente desde esta tarea: falta una conexión administrativa al proyecto. Alternativa para bootstrap repetible compatible: `database/run_all.sql`, regenerado con fuentes 001–010 y 012 en lugar de 011. No editar salidas a mano; regenerar con Build-AvatarPatch/Build-RunAll.

Después, detener la app y ejecutarla/compilarla de nuevo desde el entorno Flutter que permita Gradle; el selector nativo nuevo no aparece mediante Hot Restart. El intento de APK de esta tarea falló antes de compilar la app con `Unable to establish loopback connection`. No hay APK ni instalación nuevos acreditados. iOS tiene descripción de acceso a galería, sin build iOS en Windows.

Demo necesaria: A selecciona JPG/PNG y confirma foto/correo; reiniciar y consultar; B no puede leer/firmar/sobrescribir objeto de A; cortar conexión, reintentar sin otro objeto; cancelar selección; comprobar permiso denegado y recuperación de actividad Android con la misma cuenta, sin subir automáticamente la imagen recuperada. Ejecutar `database/tests/004_profile_avatar_permissions.sql` aparte en desarrollo: prueba filas/políticas con rollback; no prueba los bytes del servicio Storage.

### Selector no abre después de Hot Restart

Comprobación del 8 de octubre: el APK instalado en emulator-5554 no contiene ImagePickerPlugin aunque el registrante del proyecto lo declare. Detener la ejecución Flutter anterior y abrir una terminal externa o el IDE en flutter_application_entrehuellas, después ejecutar:

```powershell
flutter run --dart-define-from-file=config/supabase.local.json -d emulator-5554
```

Esto recompila e instala la versión con selector nativo; no desinstalar ni borrar datos. Desde esta sesión la compilación vuelve a fallar por conexión loopback de Java/Gradle, antes de compilar Android. Cerrar/reabrir el APK antiguo o hacer Hot Restart no instala el plugin. El selector de galería Android no requiere agregar permisos generales de almacenamiento. Probar galería primero y luego confirmación de subida; el toast genérico no identifica por sí solo cuál de las dos etapas falló.

## Activar Mis mascotas en desarrollo

Con el esquema de acceso existente, ejecutar TODO database/patchs/005_patch_pets.sql en SQL Editor con rol postgres, sin selección parcial. El patch es generado desde plan 005/fuentes 013–018 y no depende del bucket de avatar; NO vuelve a ejecutar la migración 003 de Storage fallida. Regenerar mediante ./database/scripts/Build-PetsPatch.ps1; no editar el patch ni la migración a mano. run_all incorpora este incremento para bootstrap repetible.

No aplicado remotamente desde esta entrega. La app ofrece consulta real de mascotas; antes del patch mostrará error/reintento, nunca un supuesto listado vacío. Una vez aplicado: A registra Luna con opcionales desconocidos, abre ficha, edita y reinicia; B no consulta ni modifica esa mascota por app/REST/RPC. Probar desconexión/reintento sin duplicados y dos ediciones con versión antigua (la segunda debe rechazar conflicto sin sobrescribir). database/tests/005_pets_permissions.sql usa fixtures con rollback y pruebas de roles/normalización/versionado.

La ampliación de fotos privadas y tipo/tamaño requiere el patch 006 descrito abajo. No desinstalar para ver el incremento; reiniciar Flutter con la configuración local. El plugin de galería requiere el APK recompilado descrito antes.

## Activar tipo, tamaño y fotos privadas de mascotas

Después de aplicar 005, ejecutar **TODO** `database/patchs/006_patch_pet_gallery.sql` en Supabase de desarrollo con rol postgres, sin selección parcial. Creará columnas, RPC v2, metadata, bucket privado y políticas; no altera storage.objects ni exige cambiar su propietario. Regeneración: `./database/scripts/Build-PetGalleryPatch.ps1`; bootstrap completo: Build-RunAll. El patch no fue ejecutado remotamente desde este chat.

Esta versión de la app requiere 006: las RPC v2 validan tipo/tamaño; las anteriores se retiran de los permisos cliente para impedir bypass. Mascotas existentes se conservan; si su especie es other y no tiene detalle, al editar deberá completar el tipo. Tamaño desconocido sigue permitido.

Demo: A registra Conejo/Mediano, añade hasta tres JPG/PNG de galería, guarda y reinicia; consulta ficha/listado y retira una foto desde Editar. Cancelar galería no añade nada. Fallo de foto mantiene borrador y permite Guardar sin otra mascota/archivo; confirmar que no aparece toast de éxito antes de terminar. B no consulta/descarga/firma/sube/sobrescribe/retira archivos de A; anon sin acceso. Probar reserva incompleta, límite en RPC y recuperación de actividad Android como selección pendiente. `database/tests/006_pet_gallery_permissions.sql` usa fixtures/rollback y valida RLS/grants, no bytes reales del servicio.

Las imágenes son privadas del dueño; publicación de originales/miniaturas del QR/casos y sanitización en servidor siguen pendientes de HU-04.1. No se afirma build/instalación Android ni demo remota: el bloqueo Java/Gradle y el APK anterior sin plugin permanecen documentados hasta una compilación funcional.

## Activar eliminación de mascotas — parche 007

Después del parche 006, ejecutar TODO database/patchs/007_patch_pet_deletion.sql en SQL Editor de Supabase de desarrollo con rol postgres. Generar/verificar por database/scripts/Build-PetDeletionPatch.ps1; no editar el resultado ni reescribir migraciones aplicadas. El parche conserva las mascotas existentes y añade marcador, RPC begin_pet_deletion/finish_pet_deletion, restricciones Storage y permisos de eliminación por propietario.

Diagnóstico remoto del 9 de octubre: ambas RPC devuelven 404/PGRST202 (no disponibles en caché de esquema). La RPC create_pet_v2 del mismo proyecto sí responde 401/42501 con rol anónimo, como corresponde a una función existente protegida. Comprobación con clave pública y UUID nulo de prueba; no se intentó borrar una mascota real ni iniciar sesión como usuario. No se dispone aquí de conexión SQL administrativa y el parche NO fue aplicado remotamente.

Tras aplicar el parche, comprobar eliminación con cuenta propietaria, retirada de fotos y reintento; otra cuenta/anónimo deben seguir rechazados. Si Supabase sigue devolviendo PGRST202 después de confirmar el SQL completo, ejecutar NOTIFY pgrst, 'reload schema'; y repetir. Hot Restart actualiza los botones, pero no crea funciones del backend. No reejecutar patches 005/006 ni bootstrap entero para activar exclusivamente esta función.

## Activar archivo reversible y borrado protegido — parche008

Después de007, ejecutar TODO database/patchs/008_patch_pet_archiving.sql en el SQL Editor del mismo proyecto de desarrollo con rol postgres. Si007 aún no está aplicado, ejecutar primero su archivo completo;008 no sustituye las políticas/objetos de007. Regenerar con database/scripts/Build-PetArchivingPatch.ps1. No editar artefactos generados ni reescribir migraciones previas.

RPC para cliente autenticado:
- archive_pet(p_id, p_expected_version): archiva sin borrar fotos; bloqueada si hay casos activos.
- restore_pet(p_id, p_expected_version): restaura y conserva historial.
- begin_pet_deletion/finish_pet_deletion: mantienen protocolo de limpieza de Storage de007; ahora rechazan historial/casos activos.

Consulta activa: filtrar archived_at IS NULL; archivadas: IS NOT NULL, siempre por propietario/RLS. El parche NO cambia el listado/botones de la app actual; esa integración Flutter está pendiente. No se desplegó remotamente desde este chat.

S3 debe actualizar case_history_at y active_case_count dentro de las operaciones de casos, bajo bloqueo de mascota. No existen todavía casos de producto; la pruebaSQL usa indicadores controlados por servidor. No aplicar a un esquema externo con casos existentes sin integrar/backfill de esos indicadores. Véase ADR-014, incluyendo la transición de baja de cuenta con historial.

## Activar zonas de interés — HU-02.1 / parche010

Cuando se autorice su aplicación en desarrollo, ejecutar TODO `database/patchs/010_patch_interest_zones.sql` en el mismo proyecto Supabase configurado para la app, con rol postgres/SQL Editor. Requiere Auth y roles Supabase; no necesita volver a aplicar patches de mascotas. Regenerar con `database/scripts/Build-InterestZonesPatch.ps1`; migración versionada `20261009001000_interest_zones.sql`. La aplicación remota no se ejecutó en esta tarea.

La dependencia de mapa incorpora caché nativa/path_provider: reconstruir e instalar la app para registrar plugins; Hot Restart de un binario previo no sustituye este paso. Perfil → Zonas de interés → Añadir zona. Nombrar, mover/ampliar mapa y tocar un centro o Indicar coordenadas; definir radio y Guardar zona. Lima es encuadre inicial, no ubicación detectada. No solicita GPS.

Con A: crear dos zonas, editar radio, cancelar otra edición, reiniciar y comprobar persistencia; provocar fallo de red y reintentar con el mismo borrador; eliminar y repetir después de pérdida de respuesta. Con B/anónimo: lectura/escritura de A deben rechazarse. Ejecutar `database/tests/009_interest_zone_permissions.sql` en desarrollo para RLS/grants y guardias del servidor; sus pruebas de fixture no sustituyen las cuentas reales en la app.

Mapa de desarrollo: OSM estándar, atribución y User-Agent de app, caché HTTP de flutter_map y sin descargas offline/precarga. Proveedor sustituible con `MAP_TILE_URL`, `MAP_ATTRIBUTION`, `MAP_ATTRIBUTION_URL` al compilar; comprobar condiciones/capacidad antes de distribuir, según ADR-018. Cartografía real y comportamiento Android todavía no verificados; el mapa tiene reintento/alternativa manual. Preferencias HU-02.2 y push HU-12 siguen pendientes.

## Preferencias de alertas

Antes de abrir Perfil → Preferencias de alertas, aplicar completo `database/patchs/011_patch_alert_preferences.sql` en Supabase de desarrollo. No requiere claves adicionales ni permisos GPS/push. Guardado con sesión y clave publicable; errores de esquema no se confunden con cuenta sin preferencias. Esta entrega guarda elecciones y no envía notificaciones. Tras actualizar app, verificar guardar/reabrir/reiniciar y aislamiento entre cuentas. Ver ADR-019 y ESTADO para evidencia y pendientes.

## Activación de fotos seguras y principal — patch012 + Edge

El incremento HU-04.1/#30 y HU-04.2/#31 requiere `database/patchs/012_patch_pet_photo_processing.sql` completo tras011 **y** la Edge Function pet-photo-process antes de usar cargas de la nueva app. Procedimiento de empaquetado, despliegue y validación en [README de la función](../supabase/functions/pet-photo-process/README.md). En esta tarea no se aplicó SQL ni se desplegó: ambos artefactos están preparados para revisar.

La migración deshabilita reserva/publicación y escritura antigua de archivos desde el cliente; no aplicarla de forma aislada manteniendo la app antigua como cliente de cargas. Fotos existentes siguen privadas y visibles; processed_at nulo no acredita bytes seguros para exposición de casos. Derivados y miniaturas se mantienen en buckets privados. Antes de cerrar historias probar cámara/denegación, principal tras reinicio/retirada, reintentos, usuarios A/B y cuotas reales del runtime hosted; descargar y verificar los bytes de las dos salidas. Registrar archivos privados incompletos/huérfanos si se corta el worker durante limpieza.

Intento de APK debug del incremento (10 de octubre): `flutter build apk --debug --no-pub --dart-define-from-file=config/supabase.local.json` falla en Gradle por `java.io.IOException: Unable to establish loopback connection`, antes de compilar. No hay instalación nueva acreditada; el flujo Android debe probarse desde un entorno de compilación funcional. Pruebas Flutter/Deno/PGlite no sustituyen esa demostración.

### Fotos en la instalación real de Dokploy

La lista de contenedores y Compose aportados por el usuario confirman que
Entre Huellas no tiene servicio functions, ni detenido. La indicación previa
de deploy por project-ref era para Supabase administrado y no aplica aquí.
Seguir [supabase/self-hosted/README.md](../supabase/self-hosted/README.md).
Hay snippet de servicio, router limitado a pet-photo-process y generador de
paquete con WASM. El Compose completo preparado se obtiene con el parámetro
ComposePath del generador. Ubicación real del volumen y ruta de Kong pendientes
de leer del servidor antes de activar; no se ha desplegado remotamente.
