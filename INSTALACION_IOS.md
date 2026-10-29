# Probar Entre Huellas en iPhone desde Windows

Para iPhone 11 con iOS 18.5. Compilación Release del código actual integrado en `feature/ios-sideload`.
No convierte el APK: genera una app iOS desde el código Flutter.

## 1. Obtener la compilación

En GitHub Actions, abrir el run correcto de **iOS personal testing** y descargar
el artefacto `ios-sideload-N-intento`. Descomprimirlo en Windows. Contiene:

- `entre-huellas-ios-unsigned.ipa`: pendiente de firma personal.
- `SHA256SUMS.txt`: comparar con `Get-FileHash .\entre-huellas-ios-unsigned.ipa -Algorithm SHA256`.
- `BUILD.txt`: commit exacto, base, Flutter y Xcode.
- `Podfile.lock`: dependencias nativas resueltas por esa compilación.

El ZIP del artefacto no se arrastra a Sideloadly: usar el `.ipa` que contiene.
La descarga requiere acceso al repositorio privado y caduca a los14 días;
guardar una copia local permite renovar sin otra compilación.

## 2. Preparar Windows y el teléfono

Descargar Sideloadly exclusivamente de [sideloadly.io](https://sideloadly.io/).
Seguir sus instrucciones actuales de iTunes/iCloud y controladores Apple para
Windows. Si el teléfono no aparece, comprobar primero que lo detecta iTunes.
Conectar con cable Lightning de datos, desbloquear y aceptar **Confiar en este
ordenador** en el iPhone.

## 3. Firmar e instalar

Abrir Sideloadly, seleccionar el iPhone y arrastrar el `.ipa`. Introducir la
cuenta Apple gratuita y pulsar **Start**. La contraseña y el código de doble
factor se introducen personalmente en la herramienta, nunca en el chat, GitHub
ni scripts. No habilitar inyección de modificaciones ni cambiar el identificador
manualmente; conservar la misma configuración en futuras renovaciones.

En el iPhone, confiar en el perfil de esa cuenta desde **Ajustes → General →
VPN y gestión de dispositivos**, si aparece. Activar **Ajustes → Privacidad y
seguridad → Modo de desarrollador**, reiniciar y confirmar. Si la opción no
aparece inicialmente, completar el intento de instalación/emparejamiento y
revisar otra vez. Abrir Entre Huellas desde su icono, sin depurador ni PC conectado.

## 4. Renovar

La firma gratuita dura7 días. Renovar antes de vencer usando la misma cuenta
Apple y el mismo identificador, sobre la instalación existente: **no desinstalar**.
Puede utilizarse el mismo IPA sin recompilar. Si vence, deja de abrir hasta
renovarla; la firma no impone un contador de aperturas u horas de uso.

Sideloadly permite renovación automática con su proceso en segundo plano y el
PC encendido; el iPhone debe ser detectable por USB o Wi-Fi configurado. No
asumir que se renovará con el PC apagado. Comprobar inicialmente una renovación
manual. Los borradores locales deben conservarse, pero hace falta verificarlo.
Cada compañero usa su propia cuenta Apple. Límite gratuito de3 apps instaladas
por este método, no3 renovaciones. Las condiciones de Apple pueden cambiar.

## 5. Validación con el usuario

Comprobar apertura, login/retorno, fotos de cámara/galería, mapa/GPS y alternativa
manual, PDF/compartir, reapertura offline, borradores y fluidez. Denegar permisos
y verificar alternativas/reintento. Confirmar que una renovación conserva sesión
y borradores. La compilación no acredita estos resultados en teléfono físico.
La app usa los mismos datos/backend configurados para Android: las operaciones
reales modifican esa cuenta. Las notificaciones push no se habilitan por este proceso.

Ante un error, compartir el mensaje y etapa omitiendo contraseñas, códigos y
datos personales. No borrar la app para resolver una renovación sin respaldar
primero el trabajo local.

Referencia: [FAQ oficial de Sideloadly](https://sideloadly.io/faq).
