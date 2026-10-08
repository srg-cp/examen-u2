import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../auth/presentation/view_models/login_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entre Huellas'),
        actions: [
          LoadingShimmer(
            isLoading: login.isBusy,
            loadingLabel: 'Cerrando sesión',
            highlight: const Color(0x3324282A),
            child: IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: login.isBusy
                  ? null
                  : () => ref.read(loginViewModelProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AuthStageTransition(
              stage: 'home',
              startCovered: true,
              builder: (play) => StaggerReveal(
                count: 2,
                play: play,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const StaggerRevealItem(
                      order: 0,
                      child: Text(
                        'Tu comunidad',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const StaggerRevealItem(
                      order: 1,
                      child: Text(
                        'Aquí encontrarás las mascotas y búsquedas de tu comunidad cuando estén disponibles.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (login.isError)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          login.message!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
