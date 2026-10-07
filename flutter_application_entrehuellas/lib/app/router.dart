import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/access_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/access',
        builder: (context, state) => const AccessScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Entre Huellas')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Volver al inicio'),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
