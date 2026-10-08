import '../core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/access_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/entry_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/view_models/entry_view_model.dart';
import '../features/onboarding/presentation/state/entry_destination.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(entryViewModelProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    initialLocation: '/access',
    refreshListenable: refresh,
    redirect: (context, state) {
      final flow = ref.read(entryViewModelProvider);
      final path = switch (flow.asData?.value) {
        EntryDestination.login => '/access',
        EntryDestination.onboarding => '/onboarding',
        EntryDestination.home => '/home',
        _ => '/',
      };
      if (path == '/access' && state.uri.path == '/register') return null;
      return state.uri.path == path ? null : path;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const EntryScreen(),
        ),
      ),
      GoRoute(
        path: '/access',
        builder: (context, state) => const AccessScreen(),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 320),
          reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              OriginPageTransition(
                animation: animation,
                origin: state.extra is Rect ? state.extra as Rect : null,
                child: child,
              ),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
