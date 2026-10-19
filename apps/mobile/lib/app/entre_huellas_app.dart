import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/presentation/widgets/startup_reveal.dart';
import 'router.dart';
import 'package:go_router/go_router.dart';
import '../features/notifications/presentation/view_models/push_view_model.dart';

class EntreHuellasApp extends ConsumerStatefulWidget {
  const EntreHuellasApp({this.observeNotifications = false, super.key});
  final bool observeNotifications;
  @override
  ConsumerState<EntreHuellasApp> createState() => _EntreHuellasAppState();
}

class _EntreHuellasAppState extends ConsumerState<EntreHuellasApp> {
  GoRouter? _router;
  bool _pendingOpen = false;
  void _openInbox() {
    if (!_pendingOpen || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pendingOpen || _router == null) return;
      final path = _router!.routerDelegate.currentConfiguration.uri.path;
      // Wait for authentication and onboarding. Opening a push never authorizes a case.
      if (path == '/home' || path.startsWith('/home/')) {
        _pendingOpen = false;
        if (path != '/home/notifications') _router!.push('/home/notifications');
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_openInbox);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    if (_router != router) {
      _router?.routerDelegate.removeListener(_openInbox);
      _router = router;
      router.routerDelegate.addListener(_openInbox);
    }
    if (widget.observeNotifications) {
      ref.listen(pushViewModelProvider, (previous, next) {
        if (next.openId != (previous?.openId ?? 0)) {
          _pendingOpen = true;
          _openInbox();
        }
      });
    }
    return MaterialApp.router(
      title: 'Entre Huellas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => StartupReveal(child: child!),
      routerConfig: router,
    );
  }
}
