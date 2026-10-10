import '../core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/access_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/password_recovery_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/view_models/recovery_access_view_model.dart';
import '../features/auth/domain/entities/recovery_access.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/widgets/profile_avatar.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/pets/presentation/widgets/pets_section.dart';
import '../features/pets/presentation/screens/pet_editor_screen.dart';
import '../features/pets/presentation/screens/pet_detail_screen.dart';
import '../features/pets/domain/entities/pet.dart';
import '../features/onboarding/presentation/screens/entry_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/view_models/entry_view_model.dart';
import '../features/onboarding/presentation/state/entry_destination.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(entryViewModelProvider, (_, _) => refresh.value++);
  ref.listen(recoveryAccessViewModelProvider, (_, _) => refresh.value++);
  GoRouter? activeRouter;
  final router = GoRouter(
    initialLocation: '/access',
    refreshListenable: refresh,
    redirect: (context, state) {
      final recovery = ref.read(recoveryAccessViewModelProvider);
      if (recovery.isLoading) return state.uri.path == '/' ? null : '/';
      if (recovery.hasError ||
          recovery.asData?.value == RecoveryAccess.ready ||
          recovery.asData?.value == RecoveryAccess.invalid) {
        final navigation = activeRouter?.routeInformationProvider.value.state;
        final current = activeRouter?.routerDelegate.currentConfiguration;
        final currentTop = current?.lastOrNull?.route;
        final restoring =
            navigation is Map ||
            (navigation is RouteInformationState &&
                navigation.type == NavigatingType.restore);
        if (restoring &&
            state.uri == current?.uri &&
            currentTop is GoRoute &&
            currentTop.path == '/recover-password') {
          return null;
        }
        // During refresh of an imperatively pushed page, uri can still refer
        // to the login underneath. The top match identifies the visible flow.
        if (state.uri.path == '/recover-password' ||
            (state.topRoute is GoRoute &&
                (state.topRoute as GoRoute).path == '/recover-password')) {
          return null;
        }
        return state.uri.path == '/reset-password' ? null : '/reset-password';
      }
      final flow = ref.read(entryViewModelProvider);
      final path = switch (flow.asData?.value) {
        EntryDestination.login => '/access',
        EntryDestination.onboarding => '/onboarding',
        EntryDestination.home => '/home',
        _ => '/',
      };
      if (path == '/access' &&
          ['/register', '/recover-password'].contains(state.uri.path)) {
        return null;
      }
      if (path == '/home' && state.uri.path == '/home/profile') return null;
      if (path == '/home' && state.uri.path.startsWith('/home/pets/')) {
        return null;
      }
      return state.uri.path == path ? null : path;
    },
    routes: [
      GoRoute(
        path: '/recover-password',
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
          child: const PasswordRecoveryScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const EntryScreen(),
        ),
      ),
      GoRoute(
        path: '/access',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AccessScreen(),
        ),
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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(
          profileAvatar: ProfileAvatarButton(),
          petsContent: PetsSection(),
        ),
        routes: [
          GoRoute(
            path: 'pets/new',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      OriginPageTransition(
                        animation: animation,
                        source: state.extra is OriginPageSource
                            ? state.extra as OriginPageSource
                            : null,
                        origin: state.extra is OriginPageSource
                            ? (state.extra as OriginPageSource).bounds
                            : state.extra is Rect
                            ? state.extra as Rect
                            : null,
                        child: child,
                      ),
              child: const PetEditorScreen(petId: 'new'),
            ),
          ),
          GoRoute(
            path: 'pets/:id',
            pageBuilder: (context, state) {
              final child = PetDetailScreen(
                petId: state.pathParameters['id']!,
                savedPet: state.extra is Pet ? state.extra as Pet : null,
                canEdit: state.extra != 'inspect',
              );
              if (state.extra is! Rect) {
                return NoTransitionPage(key: state.pageKey, child: child);
              }
              return CustomTransitionPage<void>(
                key: state.pageKey,
                transitionDuration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                reverseTransitionDuration:
                    MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        OriginPageTransition(
                          animation: animation,
                          origin: state.extra as Rect,
                          child: child,
                        ),
                child: child,
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: PetEditorScreen(petId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      OriginPageTransition(
                        animation: animation,
                        origin: state.extra is Rect
                            ? state.extra as Rect
                            : null,
                        child: child,
                      ),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
  activeRouter = router;
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
