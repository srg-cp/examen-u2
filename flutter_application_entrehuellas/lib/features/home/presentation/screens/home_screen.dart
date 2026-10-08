import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_page_layout.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../auth/presentation/view_models/login_view_model.dart';

/// Minimal authenticated destination until the product Home design is approved.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppPageLayout(
        title: 'Inicio',
        reveal: true,
        revealBrand: false,
        contentBuilder: (content) => AuthStageTransition(
          stage: 'home',
          startCovered: true,
          builder: (play) =>
              StaggerReveal(count: 5, play: play, child: content),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StaggerRevealItem(
              order: 3,
              child: Text(
                'Bienvenido a Entre Huellas.',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: Color(0xFF747781),
                ),
              ),
            ),
            const SizedBox(height: 28),
            StaggerRevealItem(
              order: 4,
              child: LoadingShimmer(
                isLoading: login.isBusy,
                loadingLabel: 'Cerrando sesión',
                child: FilledButton(
                  onPressed: login.isBusy
                      ? null
                      : () =>
                            ref.read(loginViewModelProvider.notifier).signOut(),
                  style: primaryActionButtonStyle(
                    context,
                    isLoading: login.isBusy,
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ),
            ),
            if (login.isError && login.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    login.message!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB53F48),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
