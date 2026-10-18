import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'device_push_source.dart';

class FirebasePushSource implements DevicePushSource {
  FirebasePushSource({required this.supportedPlatform});
  final bool supportedPlatform;
  Future<FirebaseApp>? _initializing;
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _project = String.fromEnvironment('FIREBASE_PROJECT_ID');
  @override
  bool get configured =>
      supportedPlatform &&
      [_apiKey, _appId, _sender, _project].every((s) => s.isNotEmpty);
  Future<void> _initialize() async {
    if (!configured) return;
    await (_initializing ??= Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _sender,
        projectId: _project,
      ),
    ));
  }

  @override
  Future<bool> requestPermission() async {
    await _initialize();
    if (!configured) return false;
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  @override
  Future<String?> token() async {
    await _initialize();
    if (!configured) return null;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return null;
    }
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    return FirebaseMessaging.instance.getToken();
  }

  @override
  Future<void> deleteToken() async {
    await _initialize();
    if (!configured) return;
    await FirebaseMessaging.instance.setAutoInitEnabled(false);
    await FirebaseMessaging.instance.deleteToken();
  }

  @override
  Stream<DevicePushSignal> watch() async* {
    if (!configured) return;
    await _initialize();
    final controller = StreamController<DevicePushSignal>();
    final subscriptions = <StreamSubscription<dynamic>>[
      FirebaseMessaging.onMessageOpenedApp.listen(
        (_) => controller.add(DevicePushSignal.opened),
      ),
      FirebaseMessaging.onMessage.listen(
        (_) => controller.add(DevicePushSignal.received),
      ),
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (_) => controller.add(DevicePushSignal.tokenChanged),
      ),
    ];
    try {
      if (await FirebaseMessaging.instance.getInitialMessage() != null) {
        controller.add(DevicePushSignal.opened);
      }
      yield* controller.stream;
    } finally {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await controller.close();
    }
  }
}
