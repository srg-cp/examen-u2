import '../features/explore/presentation/widgets/explore_section.dart';
import '../features/found_cases/presentation/widgets/recovery_case_actions.dart';
import '../features/lost_cases/presentation/view_models/case_read_view_model.dart';
import '../features/pets/presentation/view_models/pet_list_view_model.dart';
import '../features/found_cases/providers/found_case_providers.dart';
import '../features/found_cases/domain/entities/found_case.dart';
import 'navigation/entity_editor_page.dart';
import 'navigation/entity_detail_page.dart';
import '../features/found_cases/presentation/screens/found_editor_screen.dart';
import '../features/found_cases/presentation/screens/found_detail_screen.dart';
import '../features/found_cases/presentation/screens/my_found_cases_screen.dart';
import 'screens/lost_report_screen.dart';
import '../features/found_cases/presentation/screens/recovery_reports_screen.dart';
import '../features/home/presentation/widgets/home_content.dart'
    show openLostReport;
import '../features/lost_cases/presentation/screens/case_detail_screen.dart';
import '../features/lost_cases/presentation/screens/my_cases_screen.dart';
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
import '../features/interest_zones/presentation/screens/interest_zones_screen.dart';
import '../features/alert_preferences/presentation/screens/alert_preferences_screen.dart';
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
      if (path == '/home' &&
          state.uri.path == '/home/found-cases/new' &&
          ((state.uri.queryParameters['case'] ?? '').trim().isEmpty ||
              !{
                'true',
                'false',
              }.contains(state.uri.queryParameters['community']))) {
        return '/home';
      }
      if (path == '/home' &&
          (state.uri.path == '/home/found-cases/new' ||
              state.uri.path == '/home/my-found-cases' ||
              state.uri.path.startsWith('/home/found-cases/') ||
              state.uri.path == '/home/lost-cases/new' ||
              state.uri.path == '/home/lost-cases/community/new' ||
              state.uri.path == '/home/my-cases' ||
              state.uri.path == '/home/my-reports' ||
              state.uri.path.startsWith('/home/cases/'))) {
        return null;
      }
      if (path == '/home' && state.uri.path == '/home/profile') return null;
      if (path == '/home' && state.uri.path == '/home/interest-zones') {
        return null;
      }
      if (path == '/home' && state.uri.path == '/home/alert-preferences') {
        return null;
      }
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
          exploreContent: ExploreSection(),
        ),
        routes: [
          GoRoute(
            path: 'my-reports',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: RecoveryReportsScreen(
                onReport: (source, onReturn) =>
                    openLostReport(source, onReturn: onReturn, radius: 28),
              ),
            ),
          ),
          GoRoute(
            path: 'found-cases/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  foundEditorContextProvider.overrideWithValue(
                    FoundEditorContext(
                      communitySearch: false,
                      targetId: state.uri.queryParameters['case'],
                      communityTarget:
                          state.uri.queryParameters['community'] == 'true',
                    ),
                  ),
                ],
                child: const FoundEditorScreen(),
              ),
            ),
          ),
          GoRoute(
            path: 'my-found-cases',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MyFoundCasesScreen(),
            ),
          ),
          GoRoute(
            path: 'found-cases/:id',
            pageBuilder: (context, state) => entityDetailPage(
              context: context,
              origin: state.extra is Rect ? state.extra as Rect : null,
              key: state.pageKey,
              child: FoundDetailScreen(id: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'lost-cases/community/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  foundEditorContextProvider.overrideWithValue(
                    const FoundEditorContext(),
                  ),
                ],
                child: const LostReportScreen(initialCommunity: true),
              ),
            ),
          ),
          GoRoute(
            path: 'lost-cases/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
              child: ProviderScope(
                overrides: [
                  foundEditorContextProvider.overrideWithValue(
                    const FoundEditorContext(),
                  ),
                ],
                child: const LostReportScreen(),
              ),
            ),
          ),
          GoRoute(
            path: 'my-cases',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const MyCasesScreen(),
            ),
          ),
          GoRoute(
            path: 'cases/:id',
            pageBuilder: (context, state) => entityDetailPage(
              context: context,
              origin: state.extra is Rect ? state.extra as Rect : null,
              key: state.pageKey,
              child: CaseDetailScreen(
                id: state.pathParameters['id']!,
                recoveryActions: (value, onChanged) => RecoveryCaseActions(
                  id: value.id,
                  community: false,
                  canResolve: value.canResolve,
                  open: value.status == 'active',
                  onChanged: () {
                    onChanged();
                    ref.invalidate(myCasesViewModelProvider);
                    ref.invalidate(petListViewModelProvider);
                    ref.invalidate(petDetailViewModelProvider);
                  },
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'alert-preferences',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const AlertPreferencesScreen(),
            ),
          ),
          GoRoute(
            path: 'pets/new',
            pageBuilder: (context, state) => entityEditorPage(
              context: context,
              key: state.pageKey,
              source: state.extra,
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
              return entityDetailPage(
                context: context,
                key: state.pageKey,
                child: child,
                origin: state.extra is Rect ? state.extra as Rect : null,
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
          GoRoute(
            path: 'interest-zones',
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const InterestZonesScreen(),
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
